//
//  AnalysisView.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import SwiftUI

/// 句子分析页
struct AnalysisView: View {

    @StateObject private var viewModel = AnalysisViewModel()

    /// 输入框焦点控制
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // 输入区域
                    inputSection

                    // 错误提示
                    if let errorMessage = viewModel.errorMessage {
                        errorBanner(errorMessage)
                    }

                    // 加载中
                    if viewModel.isLoading {
                        ProgressView("正在分析...")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                    }

                    // 分析结果
                    if let analysis = viewModel.analysis {
                        VStack(alignment: .leading, spacing: 20) {
                            sentenceCard(analysis.originalSentence)
                            componentsSection(analysis.components)
                            grammarSection(analysis.grammarPoints)
                        }
                    }
                }
                .padding()
            }
            // 滚动时自动收起键盘
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("句子解析")
            // 点击空白处收起键盘
            .contentShape(Rectangle())
            .onTapGesture {
                isInputFocused = false
            }
        }
    }

    // MARK: - 输入区域

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("输入日语句子")
                .font(.headline)

            TextEditor(text: $viewModel.inputSentence)
                .frame(minHeight: 80, maxHeight: 120)
                .padding(8)
                .background(.background.secondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.separator, lineWidth: 1)
                )
                .focused($isInputFocused)

            HStack {
                Button {
                    viewModel.clear()
                } label: {
                    Text("清空")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.borderless)

                Spacer()

                Button {
                    // 分析时收起键盘
                    isInputFocused = false
                    viewModel.analyzeSentence()
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("分析句子")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
            }
        }
        .padding()
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 错误提示

    private func errorBanner(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text(message)
                .font(.subheadline)
            Spacer()
        }
        .padding(12)
        .background(.yellow.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 结果：原句卡片

    private func sentenceCard(_ sentence: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("📝 原句")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(sentence)
                .font(.system(.title3, design: .rounded, weight: .semibold))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 结果：成分拆解

    private func componentsSection(_ components: [SentenceComponent]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔍 句子结构拆解")
                .font(.headline)

            ForEach(components) { component in
                HStack(alignment: .top, spacing: 12) {
                    Text(component.text)
                        .font(.system(.body, design: .rounded))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(component.role)
                            .font(.caption)
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.blue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 结果：语法讲解

    private func grammarSection(_ grammarPoints: [GrammarPoint]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📖 重点语法")
                .font(.headline)

            if grammarPoints.isEmpty {
                Text("未识别到常见语法。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(grammarPoints) { point in
                    grammarCard(point)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func grammarCard(_ point: GrammarPoint) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(point.name)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.indigo)
                Spacer()
                Text(point.jlptLevel.label)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.orange.opacity(0.15))
                    .clipShape(Capsule())
                if let role = point.sentenceRole {
                    Text(role)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.secondary.opacity(0.1))
                        .clipShape(Capsule())
                }
            }

            Text(point.meaning)
                .font(.subheadline)
                .fontWeight(.medium)

            Label(point.usage, systemImage: "pencil")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            Text(point.explanation)
                .font(.caption)
                .foregroundStyle(.secondary)

            // 例句
            VStack(alignment: .leading, spacing: 6) {
                Text("例句")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                ForEach(Array(point.examples.enumerated()), id: \.offset) { _, example in
                    Text("• " + example)
                        .font(.caption)
                        .padding(.horizontal, 8)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.green.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    AnalysisView()
}
