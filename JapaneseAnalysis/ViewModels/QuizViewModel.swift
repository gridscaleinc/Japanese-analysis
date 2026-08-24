//
//  QuizViewModel.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import SwiftUI

/// 每日挑战状态
enum QuizPhase: Equatable {
    case intro        // 开始页
    case answering    // 答题中
    case finished     // 已完成
}

/// 单题答题结果
struct QuizAnswerRecord: Identifiable {
    let id = UUID()
    let question: QuizQuestion
    let isCorrect: Bool
}

/// 每日挑战 ViewModel
@MainActor
final class QuizViewModel: ObservableObject {

    // MARK: - Published 状态

    @Published var phase: QuizPhase = .intro
    @Published var questions: [QuizQuestion] = []
    @Published var currentIndex = 0
    @Published var selectedIndex: Int? = nil
    @Published var answeredCount = 0
    @Published var correctCount = 0
    @Published var isAnswered = false
    @Published var answerRecords: [QuizAnswerRecord] = []

    // MARK: - 计算属性

    var currentQuestion: QuizQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    /// 已答题目（按顺序）
    var answeredQuestions: [QuizQuestion] {
        answerRecords.map { $0.question }
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex + (isAnswered ? 1 : 0)) / Double(questions.count)
    }

    // MARK: - 动作

    /// 开始新挑战
    func startChallenge() {
        questions = QuizQuestionGenerator.generateDailyChallenge()
        currentIndex = 0
        selectedIndex = nil
        answeredCount = 0
        correctCount = 0
        isAnswered = false
        answerRecords = []
        phase = .answering
    }

    /// 选择选项
    func selectOption(at index: Int) {
        guard !isAnswered, let question = currentQuestion else { return }

        selectedIndex = index
        isAnswered = true
        answeredCount += 1

        let isCorrect = index == question.correctIndex
        if isCorrect {
            correctCount += 1
        }

        answerRecords.append(QuizAnswerRecord(question: question, isCorrect: isCorrect))
    }

    /// 下一题（或结束）
    func nextQuestion() {
        guard isAnswered else { return }

        isAnswered = false
        selectedIndex = nil

        if currentIndex < questions.count - 1 {
            currentIndex += 1
        } else {
            phase = .finished
        }
    }

    /// 再来一次
    func restartChallenge() {
        startChallenge()
    }

    /// 返回首页
    func backToHome() {
        phase = .intro
        questions = []
        currentIndex = 0
        answeredCount = 0
        correctCount = 0
        isAnswered = false
        answerRecords = []
    }
}
