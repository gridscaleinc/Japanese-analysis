//
//  AIServiceConfig.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import Foundation

/// AI 调用接口配置
///
/// 集中管理 AI 服务（AICommerce 原生透传 / DeepSeek / OpenAI 兼容）的：
/// - 接口地址与路径
/// - 模型名称
/// - 请求参数（temperature / max_tokens 等）
/// - 请求头字段
/// - 超时与重试策略
///
/// 修改 AI 调用行为时，优先在此文件调整，避免散落在业务代码里的硬编码。
enum AIServiceConfig {

    // MARK: - 服务提供方

    /// AI 服务提供方（用于拼接原生透传路径）
    enum Provider: String {
        case deepseek
        case openai

        /// 原生透传的 chat/completions 路径（相对 aicommerceBaseURL）
        var chatCompletionsPath: String {
            "v1/ai/native/\(rawValue)/v1/chat/completions"
        }
    }

    /// 默认使用的 AI 服务提供方
    static let defaultProvider: Provider = .deepseek

    // MARK: - 接口路径

    /// 聊天补全接口路径（相对 aicommerceBaseURL）
    static var chatCompletionsPath: String {
        defaultProvider.chatCompletionsPath
    }

    /// 钱包查询接口路径
    static let walletPath = "v1/wallet"

    /// 取消请求接口路径模板（%@ 为 clientRequestID）
    static let cancelRequestPathTemplate = "v1/ai/client-requests/%@/cancel"

    // MARK: - 模型

    /// 可用模型
    enum Model {
        /// 对话 / 分析 / 出题默认模型
        static let chat = "deepseek-chat"
        /// 推理加强模型（复杂句子分析可选）
        static let reasoner = "deepseek-reasoner"
    }

    /// 默认模型
    static let defaultModel = Model.chat

    // MARK: - 敏感凭证（API Key / 直连地址）
    //
    // 优先级：Keychain（运行时写入）> Info.plist（xcconfig 注入）> 默认值
    // 说明：
    //   - Info.plist 的值来自 Config/AIConfig.xcconfig（提交）与 AIConfig.local.xcconfig（本地、已 gitignore）
    //   - 继续走 AICommerce 动态令牌时，apiKey 可为空，无需配置

    /// 直连第三方（DeepSeek/OpenAI）的 API Key
    static var apiKey: String {
        if let keychainValue = KeychainService.shared.apiKey, !keychainValue.isEmpty {
            return keychainValue
        }
        return infoPlistValue(for: "AI_API_KEY")
    }

    /// 直连第三方的基础地址（如 https://api.deepseek.com）
    static var directBaseURL: String {
        let value = infoPlistValue(for: "AI_BASE_URL")
        return value.isEmpty ? "https://api.deepseek.com" : value
    }

    /// 从 Info.plist 读取的默认模型名（为空时回退到内置默认模型）
    static var modelFromPlist: String {
        let value = infoPlistValue(for: "AI_MODEL")
        return value.isEmpty ? defaultModel : value
    }

    /// 是否已配置直连 API Key
    static var hasDirectAPIKey: Bool {
        !apiKey.isEmpty
    }

    /// 从 Info.plist 读取字符串（缺失或含未替换占位符时返回空串）
    private static func infoPlistValue(for key: String) -> String {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            return ""
        }
        // xcconfig 变量未定义时会保留字面量 "$(VAR)"，视为未配置
        if raw.hasPrefix("$(") {
            return ""
        }
        return raw.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - 请求参数

    /// 默认温度（0.0 - 2.0）
    static let defaultTemperature: Double = 0.7
    /// 默认最大 token 数
    static let defaultMaxTokens: Int = 2000
    /// 单次请求超时（秒）
    static let requestTimeout: TimeInterval = 60
    /// 资源超时（秒）
    static let resourceTimeout: TimeInterval = 120
    /// 401 未授权时的最大重试次数
    static let maxAuthRetries: Int = 1

    // MARK: - 计费模式

    enum BillingMode: String {
        case standard
        case premium
    }

    /// 默认计费模式
    static let defaultBillingMode: BillingMode = .standard

    // MARK: - 请求头字段名

    enum Header {
        static let authorization = "Authorization"
        static let contentType = "Content-Type"
        static let appCode = "x-aicommerce-app-code"
        static let productCode = "x-aicommerce-product-code"
        static let billingMode = "x-aicommerce-billing-mode"
        static let clientRequestID = "X-Client-Request-ID"
    }

    // MARK: - 工具方法

    /// 生成每次调用的客户端请求 ID（用于显式 Cancel）
    static func makeClientRequestID() -> String {
        "crq_\(UUID().uuidString)"
    }

    /// 构建带超时配置的 URLSession
    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = requestTimeout
        configuration.timeoutIntervalForResource = resourceTimeout
        return URLSession(configuration: configuration)
    }
}