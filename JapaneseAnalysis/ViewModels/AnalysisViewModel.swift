//
//  AnalysisViewModel.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import SwiftUI
import Combine

/// 句子分析视图模型
final class AnalysisViewModel: ObservableObject {

    // MARK: - 发布属性

    /// 用户输入的句子
    @Published var inputSentence: String = ""

    /// 分析结果
    @Published var analysis: SentenceAnalysis?

    /// 是否正在分析
    @Published var isLoading: Bool = false

    /// 错误信息
    @Published var errorMessage: String?

    // MARK: - 公开方法

    /// 执行句子分析
    func analyzeSentence() {
        let trimmed = inputSentence.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            errorMessage = "请输入要分析的日语句子"
            analysis = nil
            return
        }

        guard isJapaneseText(trimmed) else {
            errorMessage = "请输入包含日语的句子"
            analysis = nil
            return
        }

        isLoading = true
        errorMessage = nil

        // 模拟延迟，让 UI 有反馈感
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }

            let result = SentenceParserService.analyze(trimmed)
            self.analysis = result
            self.isLoading = false
        }
    }

    /// 清空输入和分析结果
    func clear() {
        inputSentence = ""
        analysis = nil
        errorMessage = nil
    }

    // MARK: - 私有方法

    /// 判断文本是否包含日语字符（平假名、片假名、汉字）
    private func isJapaneseText(_ text: String) -> Bool {
        for scalar in text.unicodeScalars {
            // 平假名 U+3040 - U+309F
            if scalar.value >= 0x3040 && scalar.value <= 0x309F { return true }
            // 片假名 U+30A0 - U+30FF
            if scalar.value >= 0x30A0 && scalar.value <= 0x30FF { return true }
            // 汉字 U+4E00 - U+9FFF
            if scalar.value >= 0x4E00 && scalar.value <= 0x9FFF { return true }
        }
        return false
    }
}
