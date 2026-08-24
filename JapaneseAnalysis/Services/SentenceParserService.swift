//
//  SentenceParserService.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import Foundation

/// 句子结构解析服务
enum SentenceParserService {

    // MARK: - 公开方法

    /// 解析整句日语，返回结构拆解和语法识别结果
    static func analyze(_ sentence: String) -> SentenceAnalysis {
        let trimmed = sentence.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1. 句子成分拆解
        let components = splitComponents(from: trimmed)

        // 2. 识别重点语法
        let grammarPoints = GrammarDictionaryService.findGrammarPoints(in: trimmed)

        return SentenceAnalysis(
            originalSentence: trimmed,
            components: components,
            grammarPoints: grammarPoints
        )
    }

    // MARK: - 成分拆解

    /// 将句子拆分成带角色标签的多个成分
    private static func splitComponents(from sentence: String) -> [SentenceComponent] {
        // 按常见的助词/标点进行切分
        // 保留助词作为前一个成分的一部分（如：日本に来てから → に、来てから 归入同一个时间条件成分）
        // 逗号单独作为一个分隔标记，两边各自成为独立成分

        // 先按逗号/顿号分句
        let clauses = splitByClauseMarkers(sentence)

        var components: [SentenceComponent] = []

        for (index, clause) in clauses.enumerated() {
            let trimmedClause = clause.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedClause.isEmpty else { continue }

            let role = roleForClause(trimmedClause, index: index, totalClauses: clauses.count)
            components.append(SentenceComponent(text: trimmedClause, role: role))
        }

        return components
    }

    /// 按逗号、顿号分句
    private static func splitByClauseMarkers(_ sentence: String) -> [String] {
        // 支持中文逗号、日文逗号、顿号
        let markers: [Character] = ["，", "、", ","]
        var clauses: [String] = []
        var current = ""

        for char in sentence {
            if markers.contains(char) {
                if !current.isEmpty {
                    clauses.append(current)
                }
                current = ""
            } else {
                current.append(char)
            }
        }

        if !current.isEmpty {
            clauses.append(current)
        }

        return clauses
    }

    /// 根据分句位置和内容推断其在句中的角色
    private static func roleForClause(_ clause: String, index: Int, totalClauses: Int) -> String {
        // 基本规则：
        // - 最后一个分句通常是谓语/主句
        // - 前面分句根据句尾特征判断

        // 特征性角色判断（从后往前）
        if clause.hasSuffix("てから") || clause.hasSuffix("から、") || clause.hasSuffix("から") {
            if index < totalClauses - 1 {
                return "时间/原因条件部分"
            }
        }

        if clause.hasSuffix("とき") || clause.hasSuffix("時") {
            return "时间状语"
        }

        if clause.hasSuffix("まで") {
            return "时间/地点状语"
        }

        if clause.hasSuffix("に") {
            if clause.count <= 4 {
                return "时间状语"
            }
            return "时间/地点状语"
        }

        if clause.hasSuffix("へ") {
            return "方向状语"
        }

        // 宾语判断：包含 "を"
        if clause.contains("を") {
            return "宾语"
        }

        // 主语判断：以 "が" 或 "は" 结束或包含
        if clause.contains("は") && clause.contains("が") {
            return "主语+主语"
        }
        if clause.contains("は") || clause.hasSuffix("が") {
            return "主题/主语"
        }

        // 谓语判断：以ます/です/する 等结尾
        if clause.hasSuffix("ます") || clause.hasSuffix("です") || clause.hasSuffix("ました") ||
           clause.hasSuffix("している") || clause.hasSuffix("ています") || clause.hasSuffix("して") {
            return "谓语"
        }

        // 如果这是最后一个分句，通常是谓语或结论
        if index == totalClauses - 1 {
            return "谓语"
        }

        // 默认：状语
        return "状语"
    }
}
