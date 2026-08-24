//
//  GrammarPoint.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import Foundation

/// JLPT 等级
enum JLPTLevel: Int, Comparable {
    case n1 = 1
    case n2 = 2
    case n3 = 3
    case n4 = 4
    case n5 = 5

    var label: String {
        switch self {
        case .n1: return "N1"
        case .n2: return "N2"
        case .n3: return "N3"
        case .n4: return "N4"
        case .n5: return "N5"
        }
    }

    /// 难度等级（数字越小越难）
    var difficultyRank: Int {
        switch self {
        case .n1: return 5
        case .n2: return 4
        case .n3: return 3
        case .n4: return 2
        case .n5: return 1
        }
    }

    static func < (lhs: JLPTLevel, rhs: JLPTLevel) -> Bool {
        lhs.difficultyRank < rhs.difficultyRank
    }

    static func == (lhs: JLPTLevel, rhs: JLPTLevel) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

/// 日语语法知识点
struct GrammarPoint: Identifiable {
    let id = UUID()

    /// 识别模式（用于在句子中匹配）
    let pattern: String

    /// 语法名称（如：〜てから）
    let name: String

    /// 语法意思
    let meaning: String

    /// 使用方法
    let usage: String

    /// 简单解释（适合日语学习者）
    let explanation: String

    /// 示例例句（2-3 个）
    let examples: [String]

    /// 在句子中扮演的成分角色（时间条件、宾语、谓语等）
    let sentenceRole: String?

    /// JLPT 等级（N1-N5）
    let jlptLevel: JLPTLevel
}
