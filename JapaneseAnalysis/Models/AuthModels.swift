//
//  AuthModels.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import Foundation

// MARK: - 配置（生产值按实际接入填入）

enum AICommerceConfig {
    /// Member Center 基础 URL
    static let membersBaseURL = URL(string: "https://members.gridscale.com")!
    /// AICommerce 基础 URL
    static let aicommerceBaseURL = URL(string: "https://aicommerce.gridscale.com")!
    /// Native client_id（AICommerce 后台“业务接入”维护；非 AppShelf 客户端必传）
    static let clientID = "japanese-learning-desktop"
    /// 产品编码（AICommerce 后台配置）
    static let productCode = "jpStudy"
    /// app_code（AppShelf 客户端可省略，默认 appshelf）
    static let appCode = "japanese-learning"
    /// Native 回调（AICommerce 后台按 client_id 自动生成）
    static let redirectURI = "com.gridscale.native.japanese-learning-desktop://auth/callback"
}

// MARK: - 凭证模型

/// Members 会话信息
struct MemberSession: Codable {
    let memberId: String
    let email: String?
    let displayName: String?
    let accessToken: String
    let accessTokenExpiresAt: Date?
    let refreshToken: String
    let refreshTokenExpiresAt: Date?
}

/// AICommerce token 信息
struct AITokenInfo: Codable {
    let memberId: String
    let accountId: String
    let accountAiToken: String?
    let tokenPreview: String?
    let tokenIssued: Bool
    let expiresAt: Date?
}

/// 登录完整结果
struct NativeLoginResult {
    let member: MemberSession
    let aiToken: AITokenInfo
}

// MARK: - 错误类型

enum AuthError: LocalizedError {
    case invalidState
    case authorizationCanceled
    case tokenExchangeFailed(String)
    case noToken
    case networkError(String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidState:
            return "state 校验失败（CSRF 防护）"
        case .authorizationCanceled:
            return "用户取消了登录"
        case .tokenExchangeFailed(let msg):
            return "换取 token 失败：\(msg)"
        case .noToken:
            return "未获取到 AI token"
        case .networkError(let msg):
            return "网络错误：\(msg)"
        case .invalidResponse:
            return "服务端返回格式异常"
        }
    }
}

enum AICommerceError: LocalizedError, Equatable {
    case notAuthenticated
    case insufficientCredits
    case entitlementInactive
    case rateLimited
    case serverError(Int)
    case invalidResponse
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "请先登录"
        case .insufficientCredits:
            return "余额不足，请前往会员中心充值"
        case .entitlementInactive:
            return "暂无使用权限"
        case .rateLimited:
            return "请求过于频繁，请稍后再试"
        case .serverError(let code):
            return "服务异常 (\(code))，请稍后再试"
        case .invalidResponse:
            return "AI 返回格式异常"
        case .networkError(let msg):
            return "网络错误：\(msg)"
        }
    }
}
