//
//  KeychainService.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import Foundation
import Security

/// Keychain 安全存储服务
/// 用于保存 accessToken / refreshToken / accountAiToken 等敏感凭证
final class KeychainService {

    static let shared = KeychainService()
    private init() {}

    // MARK: - Keys

    enum Key: String, CaseIterable {
        case accessToken
        case accessTokenExpiresAt
        case refreshToken
        case refreshTokenExpiresAt
        case accountAiToken
        case aiTokenExpiresAt
        case memberId
        case memberEmail
        case memberDisplayName
    }

    // MARK: - 保存

    func set(_ value: String, for key: Key) {
        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.japaneseanalysis.credentials",
            kSecAttrAccount as String: key.rawValue
        ]

        // 先删除旧值
        SecItemDelete(query as CFDictionary)

        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        SecItemAdd(attributes as CFDictionary, nil)
    }

    // MARK: - 读取

    func get(_ key: Key) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.japaneseanalysis.credentials",
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - 删除

    func delete(_ key: Key) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.japaneseanalysis.credentials",
            kSecAttrAccount as String: key.rawValue
        ]
        SecItemDelete(query as CFDictionary)
    }

    func clearAll() {
        for key in Key.allCases {
            delete(key)
        }
    }

    // MARK: - 快速访问凭证

    var accessToken: String? {
        get { get(.accessToken) }
        set {
            if let newValue { set(newValue, for: .accessToken) }
            else { delete(.accessToken) }
        }
    }

    var refreshToken: String? {
        get { get(.refreshToken) }
        set {
            if let newValue { set(newValue, for: .refreshToken) }
            else { delete(.refreshToken) }
        }
    }

    var accountAiToken: String? {
        get { get(.accountAiToken) }
        set {
            if let newValue { set(newValue, for: .accountAiToken) }
            else { delete(.accountAiToken) }
        }
    }

    var memberId: String? {
        get { get(.memberId) }
        set {
            if let newValue { set(newValue, for: .memberId) }
            else { delete(.memberId) }
        }
    }

    var memberEmail: String? {
        get { get(.memberEmail) }
        set {
            if let newValue { set(newValue, for: .memberEmail) }
            else { delete(.memberEmail) }
        }
    }

    var memberDisplayName: String? {
        get { get(.memberDisplayName) }
        set {
            if let newValue { set(newValue, for: .memberDisplayName) }
            else { delete(.memberDisplayName) }
        }
    }
}
