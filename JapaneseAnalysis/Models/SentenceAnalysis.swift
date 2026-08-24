//
//  SentenceAnalysis.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import Foundation

/// 句子解析结果
struct SentenceAnalysis: Identifiable {
    let id = UUID()

    /// 原始输入句子
    let originalSentence: String

    /// 句子成分拆解列表
    let components: [SentenceComponent]

    /// 识别出的重点语法
    let grammarPoints: [GrammarPoint]
}

/// 句子成分（结构拆解）
struct SentenceComponent: Identifiable {
    let id = UUID()

    /// 成分文本（如：日本に来てから）
    let text: String

    /// 成分角色（如：时间条件部分、时间状语、宾语、谓语）
    let role: String
}
