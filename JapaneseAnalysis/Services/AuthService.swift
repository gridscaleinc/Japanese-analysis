//
//  AuthService.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import Foundation
import AuthenticationServices
import CommonCrypto
#if os(macOS)
import AppKit
#endif

/// 认证服务：Members Native PKCE 登录流程
/// 流程：生成 PKCE → 打开浏览器授权 → 回调拿 code → 换 token → 存 Keychain
@MainActor
final class AuthService: NSObject, ObservableObject {

    static let shared = AuthService()

    @Published var isLoggedIn: Bool {
        didSet {
            NotificationCenter.default.post(name: .authStateChanged, object: nil)
        }
    }
    @Published var memberEmail: String?
    @Published var memberDisplayName: String?

    private var pendingVerifier: String?
    private var pendingState: String?
    private var authSession: ASWebAuthenticationSession?

    private override init() {
        // 从 Keychain 恢复登录状态
        let hasToken = KeychainService.shared.accountAiToken != nil || KeychainService.shared.refreshToken != nil
        self.isLoggedIn = hasToken
        self.memberEmail = KeychainService.shared.memberEmail
        self.memberDisplayName = KeychainService.shared.memberDisplayName
        super.init()
    }

    // MARK: - PKCE 工具

    private func generateCodeVerifier() -> String {
        let charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"
        let length = 64
        let random = (0..<length).map { _ in
            let offset = Int.random(in: 0..<charset.count)
            let startIndex = charset.index(charset.startIndex, offsetBy: offset)
            return String(charset[startIndex])
        }
        return random.joined()
    }

    private func base64URLEncode(_ data: Data) -> String {
        var base64 = data.base64EncodedString()
        base64 = base64.replacingOccurrences(of: "+", with: "-")
        base64 = base64.replacingOccurrences(of: "/", with: "_")
        base64 = base64.replacingOccurrences(of: "=", with: "")
        return base64
    }

    private func generateCodeChallenge(from verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hash = sha256(data)
        return base64URLEncode(hash)
    }

    private func sha256(_ data: Data) -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }

    // MARK: - 登录

    /// 开始 PKCE 登录（桌面端打开浏览器）
    func login() async throws {
        // 生成 PKCE
        let verifier = generateCodeVerifier()
        let challenge = generateCodeChallenge(from: verifier)
        let state = UUID().uuidString

        pendingVerifier = verifier
        pendingState = state

        // 构建 authorize URL
        var components = URLComponents(url: AICommerceConfig.membersBaseURL.appendingPathComponent("api/native/authorize"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: AICommerceConfig.clientID),
            URLQueryItem(name: "product_code", value: AICommerceConfig.productCode),
            URLQueryItem(name: "redirect_uri", value: AICommerceConfig.redirectURI),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "code_challenge", value: challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]

        guard let url = components.url else {
            throw AuthError.invalidResponse
        }

        // 打开浏览器进行授权
        let code = try await performAuthorization(url: url)

        // 校验 state
        guard let pendingState, state == pendingState else {
            throw AuthError.invalidState
        }

        // 换 token
        guard let verifier = pendingVerifier else {
            throw AuthError.invalidState
        }

        let result = try await exchangeCodeForToken(code: code, verifier: verifier)

        // 保存到 Keychain
        await saveSession(result)
    }

    /// 使用 ASWebAuthenticationSession 执行授权（macOS 13+ / iOS 15+）
    private func performAuthorization(url: URL) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            var capturedContinuation: CheckedContinuation<String, Error>? = continuation

            let handler: ASWebAuthenticationSession.CompletionHandler = { callbackURL, error in
                if let error = error as? ASWebAuthenticationSessionError {
                    if error.code == .canceledLogin {
                        capturedContinuation?.resume(throwing: AuthError.authorizationCanceled)
                    } else {
                        capturedContinuation?.resume(throwing: AuthError.networkError(error.localizedDescription))
                    }
                    capturedContinuation = nil
                    return
                }

                guard let callbackURL else {
                    capturedContinuation?.resume(throwing: AuthError.invalidResponse)
                    capturedContinuation = nil
                    return
                }

                // 解析回调 URL 中的 code
                guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                      let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
                    capturedContinuation?.resume(throwing: AuthError.invalidResponse)
                    capturedContinuation = nil
                    return
                }

                capturedContinuation?.resume(returning: code)
                capturedContinuation = nil
            }

            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: redirectScheme, completionHandler: handler)
            session.presentationContextProvider = self
            self.authSession = session
            session.start()
        }
    }

    private var redirectScheme: String {
        // 从 redirectURI 提取 scheme，如 "com.gridscale.native.japanese-learning-desktop"
        guard let url = URL(string: AICommerceConfig.redirectURI) else { return "com.gridscale.native" }
        return url.scheme ?? "com.gridscale.native"
    }

    // MARK: - 换 token

    private func exchangeCodeForToken(code: String, verifier: String) async throws -> NativeLoginResult {
        let url = AICommerceConfig.membersBaseURL.appendingPathComponent("api/native/token")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "code": code,
            "code_verifier": verifier,
            "redirect_uri": AICommerceConfig.redirectURI
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "unknown"
            throw AuthError.tokenExchangeFailed(errorBody)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let ok = json["ok"] as? Bool, ok else {
            throw AuthError.invalidResponse
        }

        // 解析 member
        guard let memberJSON = json["member"] as? [String: Any],
              let memberID = memberJSON["id"] as? String else {
            throw AuthError.invalidResponse
        }

        // 解析 session
        guard let sessionJSON = json["session"] as? [String: Any],
              let accessToken = sessionJSON["accessToken"] as? String,
              let refreshToken = sessionJSON["refreshToken"] as? String else {
            throw AuthError.invalidResponse
        }

        // 解析 token
        guard let tokenJSON = json["token"] as? [String: Any],
              let accountID = tokenJSON["accountId"] as? String,
              let tokenIssued = tokenJSON["tokenIssued"] as? Bool else {
            throw AuthError.invalidResponse
        }

        let member = MemberSession(
            memberId: memberID,
            email: memberJSON["email"] as? String,
            displayName: memberJSON["displayName"] as? String ?? memberJSON["name"] as? String,
            accessToken: accessToken,
            accessTokenExpiresAt: ISO8601DateFormatter().date(from: sessionJSON["accessTokenExpiresAt"] as? String ?? ""),
            refreshToken: refreshToken,
            refreshTokenExpiresAt: ISO8601DateFormatter().date(from: sessionJSON["refreshTokenExpiresAt"] as? String ?? "")
        )

        let aiToken = AITokenInfo(
            memberId: memberID,
            accountId: accountID,
            accountAiToken: tokenJSON["accountAiToken"] as? String,
            tokenPreview: tokenJSON["tokenPreview"] as? String,
            tokenIssued: tokenIssued,
            expiresAt: ISO8601DateFormatter().date(from: tokenJSON["expiresAt"] as? String ?? "")
        )

        return NativeLoginResult(member: member, aiToken: aiToken)
    }

    // MARK: - 会话管理

    /// 保存登录结果到 Keychain
    private func saveSession(_ result: NativeLoginResult) async {
        let keychain = KeychainService.shared
        keychain.accessToken = result.member.accessToken
        keychain.refreshToken = result.member.refreshToken
        keychain.memberId = result.member.memberId
        keychain.memberEmail = result.member.email
        keychain.memberDisplayName = result.member.displayName

        // AI token 可能为 null（已有有效 token 时 bootstrap 返回 preview 而非完整值）
        if let aiToken = result.aiToken.accountAiToken {
            keychain.accountAiToken = aiToken
        }

        isLoggedIn = true
        memberEmail = result.member.email
        memberDisplayName = result.member.displayName
    }

    /// 登出
    func logout() async {
        // 通知服务端吊销 refreshToken
        if let refreshToken = KeychainService.shared.refreshToken {
            let url = AICommerceConfig.membersBaseURL.appendingPathComponent("api/native/logout")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: ["refresh_token": refreshToken])
            _ = try? await URLSession.shared.data(for: request)
        }

        KeychainService.shared.clearAll()
        isLoggedIn = false
        memberEmail = nil
        memberDisplayName = nil
    }

    /// 刷新 AI token（accessToken 有效时）
    func resetAIToken() async throws {
        guard let accessToken = KeychainService.shared.accessToken else {
            throw AuthError.noToken
        }

        let url = AICommerceConfig.membersBaseURL.appendingPathComponent("api/native/ai-token/reset")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = Data()

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw AuthError.networkError("刷新 token 失败")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tokenJSON = json["token"] as? [String: Any],
              let newToken = tokenJSON["accountAiToken"] as? String else {
            throw AuthError.invalidResponse
        }

        KeychainService.shared.accountAiToken = newToken
    }

    /// 刷新 Members 会话（refreshToken 有效时）
    func refreshSession() async throws {
        guard let refreshToken = KeychainService.shared.refreshToken else {
            throw AuthError.noToken
        }

        let url = AICommerceConfig.membersBaseURL.appendingPathComponent("api/native/refresh")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["refresh_token": refreshToken])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw AuthError.networkError("刷新会话失败")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let sessionJSON = json["session"] as? [String: Any],
              let newAccess = sessionJSON["accessToken"] as? String,
              let newRefresh = sessionJSON["refreshToken"] as? String else {
            throw AuthError.invalidResponse
        }

        KeychainService.shared.accessToken = newAccess
        KeychainService.shared.refreshToken = newRefresh
    }

    /// 确保有可用的 accountAiToken（失效时自动恢复）
    func ensureValidAIToken() async throws -> String {
        if let token = KeychainService.shared.accountAiToken {
            return token
        }

        // 尝试用 accessToken reset
        if KeychainService.shared.accessToken != nil {
            try await resetAIToken()
            if let token = KeychainService.shared.accountAiToken {
                return token
            }
        }

        // 尝试 refresh
        if KeychainService.shared.refreshToken != nil {
            try await refreshSession()
            try await resetAIToken()
            if let token = KeychainService.shared.accountAiToken {
                return token
            }
        }

        // 需要重新登录
        throw AuthError.noToken
    }
}

extension Notification.Name {
    static let authStateChanged = Notification.Name("authStateChanged")
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension AuthService: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        #if os(macOS)
        return NSApp.keyWindow ?? NSWindow()
        #else
        return ASPresentationAnchor()
        #endif
    }
}
