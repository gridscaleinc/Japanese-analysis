//
//  QuizQuestion.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import Foundation

/// 题目类型
enum QuizQuestionType {
    case grammar
    case vocabulary
}

/// 每日挑战题目
struct QuizQuestion: Identifiable {
    let id = UUID()

    /// 题目类型（语法 / 词汇）
    let type: QuizQuestionType

    /// 题干（含空槽 ____）
    let stem: String

    /// 4 个选项（已随机打乱）
    let options: [String]

    /// 正确选项索引（基于打乱后的 options）
    let correctIndex: Int

    /// 中文解析
    let explanation: String

    /// 对应 JLPT 级别
    let jlptLevel: String
}
