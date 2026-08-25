//
//  AICommerceService.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import Foundation

/// AICommerce 服务：调 AI 动态出题
/// 使用原生协议透传（OpenAI 兼容），不查 capability_alias，直接 POST /v1/ai/native/deepseek/v1/chat/completions
@MainActor
final class AICommerceService {

    static let shared = AICommerceService()
    private init() {}

    // MARK: - 动态出题

    /// 让 AI 生成每日挑战题目（JSON 数组）
    func generateQuizQuestions(count: Int = 5) async throws -> [QuizQuestion] {
        // 获取有效 token
        let token = try await AuthService.shared.ensureValidAIToken()

        // 构建 prompt
        let prompt = buildQuizPrompt(count: count)

        // 调用原生 OpenAI 兼容端点
        let responseJSON = try await chatCompletion(
            token: token,
            model: "deepseek-chat",
            messages: ["role": "user", "content": prompt]
        )

        // 解析 AI 回复
        guard let content = responseJSON["choices"] as? [[String: Any]],
              let first = content.first,
              let message = first["message"] as? [String: Any],
              let text = message["content"] as? String else {
            throw AICommerceError.invalidResponse
        }

        // 解析 JSON 数组
        return try parseQuestionsJSON(text, count: count)
    }

    // MARK: - 句子分析

    /// 让 AI 分析日语句子，返回结构化拆解结果
    func analyzeSentence(_ sentence: String) async throws -> SentenceAnalysis {
        // 获取有效 token
        let token = try await AuthService.shared.ensureValidAIToken()

        // 构建 prompt
        let prompt = buildAnalysisPrompt(sentence: sentence)

        // 调用原生 OpenAI 兼容端点
        let responseJSON = try await chatCompletion(
            token: token,
            model: "deepseek-chat",
            messages: ["role": "user", "content": prompt]
        )

        // 解析 AI 回复
        guard let content = responseJSON["choices"] as? [[String: Any]],
              let first = content.first,
              let message = first["message"] as? [String: Any],
              let text = message["content"] as? String else {
            throw AICommerceError.invalidResponse
        }

        // 解析 JSON
        return try parseAnalysisJSON(text, originalSentence: sentence)
    }

    private func buildAnalysisPrompt(sentence: String) -> String {
        """
        你是一位专业的日语语言学专家和 JLPT 语法讲师。请分析下面这句日语：

        「\(sentence)」

        请完成以下分析：

        1. 句子成分拆解：将句子按语法功能拆分为多个成分（主语、时间状语、宾语、谓语等），
           每个成分包含：原文文本 + 成分角色（使用简体中文，如“时间状语”“宾语”“谓语”“主题”“条件从句”等）

        2. 重点语法识别：找出句中使用的语法句型（如 〜てから、〜ために、〜わけにはいかない 等），
           每个语法包含：
           - pattern：语法模式（如 "てから"）
           - name：语法名称（如 "〜てから"）
           - meaning：语法意思（如 "…之后"）
           - usage：使用方法（接续方式，如 "动词て形 + から"）
           - explanation：简单中文解释，适合日语学习者理解
           - examples：2-3 个中日对照例句
           - sentenceRole：该语法在句中的成分角色（如 "时间条件部分"）
           - jlptLevel：对应 JLPT 等级（"N1"-"N5"）

        请严格按以下 JSON 格式输出，不要输出任何其他内容：

        {
          "components": [
            {
              "text": "成分文本",
              "role": "成分角色"
            }
          ],
          "grammarPoints": [
            {
              "pattern": "语法模式",
              "name": "语法名称",
              "meaning": "语法意思",
              "usage": "使用方法",
              "explanation": "中文解释",
              "examples": ["例1", "例2", "例3"],
              "sentenceRole": "句中的成分角色",
              "jlptLevel": "N3"
            }
          ]
        }

        要求：
        - components 必须覆盖整个句子的所有部分，不要遗漏
        - grammarPoints 中识别出句中实际使用的语法；如果识别不到 2 个以上，至少要给出 1 个最明显的
        - jlptLevel 可以是 "N1"、"N2"、"N3"、"N4"、"N5" 之一
        - examples 中的句子要用中文括号标注意思
        """
    }

    private func parseAnalysisJSON(_ text: String, originalSentence: String) throws -> SentenceAnalysis {
        // 清理可能包含的 markdown 代码块标记
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("```json") {
            cleaned = String(cleaned.dropFirst(7))
        }
        if cleaned.hasPrefix("```") {
            cleaned = String(cleaned.dropFirst(3))
        }
        if cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropLast(3))
        }
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AICommerceError.invalidResponse
        }

        // 解析 components
        var components: [SentenceComponent] = []
        if let componentsJSON = json["components"] as? [[String: Any]] {
            for item in componentsJSON.prefix(10) {
                guard let text = item["text"] as? String,
                      let role = item["role"] as? String else { continue }
                components.append(SentenceComponent(text: text, role: role))
            }
        }

        // 解析 grammarPoints
        var grammarPoints: [GrammarPoint] = []
        if let grammarJSON = json["grammarPoints"] as? [[String: Any]] {
            for item in grammarJSON.prefix(5) {
                guard let pattern = item["pattern"] as? String,
                      let name = item["name"] as? String,
                      let meaning = item["meaning"] as? String,
                      let usage = item["usage"] as? String else { continue }

                let explanation = item["explanation"] as? String ?? meaning
                let examples = item["examples"] as? [String] ?? []
                let sentenceRole = item["sentenceRole"] as? String

                let jlptRaw = item["jlptLevel"] as? String ?? "N3"
                let level: JLPTLevel
                switch jlptRaw.uppercased() {
                case "N1": level = .n1
                case "N2": level = .n2
                case "N4": level = .n4
                case "N5": level = .n5
                default: level = .n3
                }

                grammarPoints.append(GrammarPoint(
                    pattern: pattern,
                    name: name,
                    meaning: meaning,
                    usage: usage,
                    explanation: explanation,
                    examples: examples,
                    sentenceRole: sentenceRole,
                    jlptLevel: level
                ))
            }
        }

        // 至少要有 components，否则解析失败
        guard !components.isEmpty else {
            throw AICommerceError.invalidResponse
        }

        return SentenceAnalysis(
            originalSentence: originalSentence,
            components: components,
            grammarPoints: grammarPoints
        )
    }

    // MARK: - 查钱包

    /// 查询钱包余额
    func fetchWalletBalance() async throws -> Int {
        let token = try await AuthService.shared.ensureValidAIToken()

        let url = AICommerceConfig.aicommerceBaseURL.appendingPathComponent("v1/wallet")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, http.statusCode == 401 {
                try await AuthService.shared.resetAIToken()
                let token2 = try await AuthService.shared.ensureValidAIToken()
                request.setValue("Bearer \(token2)", forHTTPHeaderField: "Authorization")
                let (data2, response2) = try await URLSession.shared.data(for: request)
                if let http2 = response2 as? HTTPURLResponse, http2.statusCode == 200 {
                    return try parseBalance(from: data2)
                }
            }
            return try parseBalance(from: data)
        } catch let error as AICommerceError {
            throw error
        } catch {
            throw AICommerceError.networkError(error.localizedDescription)
        }
    }

    private func parseBalance(from data: Data) throws -> Int {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let balance = json["balance_credits"] as? Int else {
            throw AICommerceError.invalidResponse
        }
        return balance
    }

    // MARK: - 原生 OpenAI 兼容调用

    /// 调用原生 OpenAI 兼容端点（deepseek）
    /// POST {AICOMMERCE_BASE_URL}/v1/ai/native/deepseek/v1/chat/completions
    private func chatCompletion(token: String, model: String, messages: [String: String], attempt: Int = 0) async throws -> [String: Any] {
        let baseURL = AICommerceConfig.aicommerceBaseURL
        let url = baseURL.appendingPathComponent("v1/ai/native/deepseek/v1/chat/completions")

        // 生成每次调用的 X-Client-Request-ID（用于显式 Cancel）
        let clientRequestID = "crq_\(UUID().uuidString)"

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // 产品上下文头
        request.setValue(AICommerceConfig.appCode, forHTTPHeaderField: "x-aicommerce-app-code")
        request.setValue(AICommerceConfig.productCode, forHTTPHeaderField: "x-aicommerce-product-code")
        request.setValue("standard", forHTTPHeaderField: "x-aicommerce-billing-mode")
        request.setValue(clientRequestID, forHTTPHeaderField: "X-Client-Request-ID")

        let body: [String: Any] = [
            "model": model,
            "messages": [messages],
            "temperature": 0.7,
            "max_tokens": 2000
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw AICommerceError.invalidResponse
            }

            switch http.statusCode {
            case 200..<300:
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    throw AICommerceError.invalidResponse
                }
                return json
            case 401:
                // token 失效 → 重置并重试（只重试一次，防止无限递归）
                guard attempt < 1 else {
                    throw AICommerceError.notAuthenticated
                }
                try await AuthService.shared.resetAIToken()
                let newToken = try await AuthService.shared.ensureValidAIToken()
                return try await chatCompletion(token: newToken, model: model, messages: messages, attempt: attempt + 1)
            case 402:
                throw AICommerceError.insufficientCredits
            case 403:
                throw AICommerceError.entitlementInactive
            case 429:
                throw AICommerceError.rateLimited
            default:
                let bodyText = String(data: data, encoding: .utf8) ?? ""
                throw AICommerceError.serverError(http.statusCode)
            }
        } catch let error as AICommerceError {
            throw error
        } catch {
            throw AICommerceError.networkError(error.localizedDescription)
        }
    }

    // MARK: - 取消请求

    /// 停止指定请求（用户在 UI 点击 Stop 时调用）
    func cancelRequest(clientRequestID: String) async throws {
        let token = try await AuthService.shared.ensureValidAIToken()

        let baseURL = AICommerceConfig.aicommerceBaseURL
        let encodedID = clientRequestID.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? clientRequestID
        let url = baseURL.appendingPathComponent("v1/ai/client-requests/\(encodedID)/cancel")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "app_code": AICommerceConfig.appCode,
            "product_code": AICommerceConfig.productCode
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                throw AICommerceError.serverError((response as? HTTPURLResponse)?.statusCode ?? 0)
            }
            _ = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        } catch let error as AICommerceError {
            throw error
        } catch {
            throw AICommerceError.networkError(error.localizedDescription)
        }
    }

    // MARK: - Prompt 构建与解析

    private func buildQuizPrompt(count: Int) -> String {
        """
        你是一位专业的日语能力考试（JLPT）出题专家。请为我生成 \(count) 道日语 N2-N3 水平的每日挑战题。

        要求：
        1. 题目类型：3 道语法 + 2 道词汇（语法题考察文法句型，词汇题考察读音或词义）
        2. 每道题必须包含：题干（日文句子，需要填空的地方用 ____ 表示）、4个选项（A/B/C/D）、正确答案索引（0-3）、中文解析、JLPT级别
        3. 难度控制：N2-N3 范围，避免过难或过易
        4. 出题范围：常见语法句型（如 〜わけにはいかない、〜に限らず、〜ものの 等）和常用词汇

        请严格按以下 JSON 数组格式输出，不要输出任何其他内容：

        [
          {
            "type": "grammar" 或 "vocabulary",
            "stem": "日文题干，需要填空的地方用 ____ 表示",
            "options": ["选项A", "选项B", "选项C", "选项D"],
            "correctIndex": 0,
            "explanation": "中文解析，解释为什么选这个答案",
            "jlptLevel": "N2"
          }
        ]

        注意：correctIndex 必须是 options 数组中正确选项的索引（从 0 开始）。
        """
    }

    private func parseQuestionsJSON(_ text: String, count: Int) throws -> [QuizQuestion] {
        // 清理可能包含的 markdown 代码块标记
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("```json") {
            cleaned = String(cleaned.dropFirst(7))
        }
        if cleaned.hasPrefix("```") {
            cleaned = String(cleaned.dropFirst(3))
        }
        if cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropLast(3))
        }
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8),
              let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw AICommerceError.invalidResponse
        }

        var questions: [QuizQuestion] = []
        var usedStems = Set<String>()

        for item in jsonArray.prefix(count) {
            guard let stem = item["stem"] as? String,
                  let optionsRaw = item["options"] as? [String],
                  optionsRaw.count >= 4,
                  let correctIndex = item["correctIndex"] as? Int,
                  correctIndex >= 0 && correctIndex < optionsRaw.count,
                  let explanation = item["explanation"] as? String else {
                continue
            }

            // 去重
            let normalizedStem = stem.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !usedStems.contains(normalizedStem) else { continue }
            usedStems.insert(normalizedStem)

            let typeRaw = item["type"] as? String ?? "grammar"
            let type: QuizQuestionType = typeRaw == "vocabulary" ? .vocabulary : .grammar
            let jlpt = item["jlptLevel"] as? String ?? "N3"

            questions.append(QuizQuestion(
                type: type,
                stem: normalizedStem,
                options: Array(optionsRaw.prefix(4)),
                correctIndex: correctIndex,
                explanation: explanation,
                jlptLevel: jlpt
            ))
        }

        guard !questions.isEmpty else {
            throw AICommerceError.invalidResponse
        }

        return questions
    }
}
