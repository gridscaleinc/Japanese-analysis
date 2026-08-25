//
//  QuizView.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import SwiftUI

/// 每日挑战页
struct QuizView: View {

    @StateObject private var viewModel = QuizViewModel()

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.phase {
                case .intro:
                    introView
                case .answering:
                    answeringView
                case .finished:
                    finishedView
                }
            }
            .navigationTitle("每日挑战")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - 开始页

    private var introView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 20)

                Image(systemName: "pencil.and.list.clipboard")
                    .font(.system(size: 64))
                    .foregroundStyle(.teal)
                    .frame(width: 120, height: 120)
                    .background(.teal.opacity(0.12))
                    .clipShape(Circle())

                Text("每日挑战")
                    .font(.system(.title, design: .rounded, weight: .bold))

                Text("挑战 N2-N3 语法与词汇，每天 5 题，日积月累，稳步提升！")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                HStack(spacing: 16) {
                    featureBadge(icon: "text.bubble.fill", text: "语法词汇")
                    featureBadge(icon: "checkmark.circle.fill", text: "即时反馈")
                    featureBadge(icon: "lightbulb.fill", text: "详细解析")
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("如何使用")
                        .font(.headline)
                        .padding(.bottom, 4)

                    infoRow(number: "1", text: "在首页点击\"每日挑战\"进入")
                    infoRow(number: "2", text: "点击\"开始挑战\"生成专属 5 道题目")
                    infoRow(number: "3", text: "选择答案后立即查看正确/错误反馈")
                    infoRow(number: "4", text: "每题配有中文解析，随时查漏补缺")
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background.secondary)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                if let loadError = viewModel.loadError {
                    Label(loadError, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .padding(.horizontal)
                }

                Button {
                    viewModel.startChallenge()
                } label: {
                    HStack {
                        if viewModel.isLoadingQuestions {
                            ProgressView()
                                .tint(.white)
                            Text("AI 出题中…")
                        } else {
                            Text("开始挑战")
                        }
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.teal)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(viewModel.isLoadingQuestions)
                .padding(.top, 8)

                Spacer(minLength: 20)
            }
            .padding()
        }
    }

    private func featureBadge(icon: String, text: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.teal)
            Text(text)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func infoRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(.teal)
                .clipShape(Circle())
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }

    // MARK: - 答题页

    private var answeringView: some View {
        VStack(spacing: 0) {
            // 进度条
            ProgressView(value: viewModel.progress)
                .tint(.teal)
                .padding(.horizontal)
                .padding(.top, 8)

            // 题目信息
            HStack {
                Text("第 \(viewModel.currentIndex + 1) / \(viewModel.questions.count) 题")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("得分 \(viewModel.correctCount) / \(viewModel.answeredCount)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.teal)
            }
            .padding(.horizontal)
            .padding(.top, 12)

            if let question = viewModel.currentQuestion {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // 题目类型标签
                        HStack {
                            Text(question.type == .grammar ? "语法" : "词汇")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.teal)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.teal.opacity(0.12))
                                .clipShape(Capsule())

                            Text(question.jlptLevel)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.orange)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.orange.opacity(0.12))
                                .clipShape(Capsule())
                        }

                        // 题干
                        Text(question.stem)
                            .font(.system(.title3, design: .rounded, weight: .medium))
                            .padding(.top, 4)

                        // 选项
                        VStack(spacing: 12) {
                            ForEach(0..<question.options.count, id: \.self) { index in
                                optionButton(question: question, index: index)
                            }
                        }
                        .padding(.top, 8)

                        // 解析（答完后显示）
                        if viewModel.isAnswered {
                            explanationCard(question)
                        }
                    }
                    .padding()
                }

                // 下一题按钮
                if viewModel.isAnswered {
                    Button {
                        viewModel.nextQuestion()
                    } label: {
                        Text(viewModel.currentIndex < viewModel.questions.count - 1 ? "下一题" : "查看结果")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.teal)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isAnswered)
    }

    private func optionButton(question: QuizQuestion, index: Int) -> some View {
        let isSelected = viewModel.selectedIndex == index
        let isCorrect = index == question.correctIndex
        let showResult = viewModel.isAnswered

        return Button {
            viewModel.selectOption(at: index)
        } label: {
            HStack(spacing: 12) {
                // 选项字母
                Text(["A", "B", "C", "D"][index])
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(optionColor(index: index, isSelected: isSelected, isCorrect: isCorrect, showResult: showResult))
                    .frame(width: 30, height: 30)
                    .background(optionColor(index: index, isSelected: isSelected, isCorrect: isCorrect, showResult: showResult).opacity(0.12))
                    .clipShape(Circle())

                // 选项内容
                Text(question.options[index])
                    .font(.body)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // 结果图标
                if showResult {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
            .padding(12)
            .background(optionBackground(index: index, isSelected: isSelected, isCorrect: isCorrect, showResult: showResult))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(optionBorder(index: index, isSelected: isSelected, isCorrect: isCorrect, showResult: showResult), lineWidth: 1.5)
            )
        }
        .disabled(showResult)
        .buttonStyle(.plain)
    }

    private func optionColor(index: Int, isSelected: Bool, isCorrect: Bool, showResult: Bool) -> Color {
        if showResult {
            if isCorrect { return .green }
            if isSelected { return .red }
            return .secondary
        }
        return isSelected ? .teal : .secondary
    }

    private func optionBackground(index: Int, isSelected: Bool, isCorrect: Bool, showResult: Bool) -> Color {
        if showResult {
            if isCorrect { return .green.opacity(0.1) }
            if isSelected { return .red.opacity(0.1) }
        }
        return isSelected ? .teal.opacity(0.06) : Color.secondary.opacity(0.06)
    }

    private func optionBorder(index: Int, isSelected: Bool, isCorrect: Bool, showResult: Bool) -> Color {
        if showResult {
            if isCorrect { return .green.opacity(0.5) }
            if isSelected { return .red.opacity(0.5) }
        }
        return isSelected ? .teal : Color.gray.opacity(0.3)
    }

    private func explanationCard(_ question: QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("解析")
                    .font(.headline)
                Spacer()
                Text(viewModel.selectedIndex == question.correctIndex ? "回答正确 🎉" : "回答错误")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(viewModel.selectedIndex == question.correctIndex ? .green : .red)
            }

            Text(question.explanation)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(.yellow.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.yellow.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - 完成页

    private var finishedView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 20)

                // 结果图标
                let ratio = Double(viewModel.correctCount) / Double(max(viewModel.questions.count, 1))

                Image(systemName: resultIcon(ratio: ratio))
                    .font(.system(size: 64))
                    .foregroundStyle(resultColor(ratio: ratio))
                    .frame(width: 120, height: 120)
                    .background(resultColor(ratio: ratio).opacity(0.12))
                    .clipShape(Circle())

                Text(resultTitle(ratio: ratio))
                    .font(.system(.title2, design: .rounded, weight: .bold))

                Text(resultSubtitle(ratio: ratio))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // 分数卡
                HStack(spacing: 16) {
                    resultStat(value: "\(viewModel.correctCount)", label: "答对", color: .green)
                    resultStat(value: "\(viewModel.questions.count - viewModel.correctCount)", label: "答错", color: .red)
                    resultStat(value: "\(Int(ratio * 100))%", label: "正确率", color: .teal)
                }

                // 回顾
                VStack(alignment: .leading, spacing: 16) {
                    Text("挑战回顾")
                        .font(.headline)

                    ForEach(Array(viewModel.answeredQuestions.enumerated()), id: \.element.id) { index, question in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 24, height: 24)
                                .background(
                                    isAnsweredCorrectly(question: question) ? .green : .red
                                )
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(question.stem)
                                    .font(.subheadline.weight(.medium))
                                Text("正确答案：\(question.options[question.correctIndex])")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background.secondary)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // 按钮
                VStack(spacing: 12) {
                    Button {
                        viewModel.restartChallenge()
                    } label: {
                        Text("再来一次")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.teal)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        viewModel.backToHome()
                    } label: {
                        Text("返回首页")
                            .font(.headline)
                            .foregroundStyle(.teal)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.teal.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 8)

                Spacer(minLength: 20)
            }
            .padding()
        }
    }

    private func isAnsweredCorrectly(question: QuizQuestion) -> Bool {
        return viewModel.answerRecords.first(where: { $0.question.id == question.id })?.isCorrect ?? false
    }

    private func resultIcon(ratio: Double) -> String {
        if ratio >= 0.8 { return "trophy.fill" }
        if ratio >= 0.6 { return "hands.clap.fill" }
        if ratio >= 0.4 { return "book.fill" }
        return "flag.checkered"
    }

    private func resultColor(ratio: Double) -> Color {
        if ratio >= 0.8 { return .yellow }
        if ratio >= 0.6 { return .teal }
        if ratio >= 0.4 { return .blue }
        return .gray
    }

    private func resultTitle(ratio: Double) -> String {
        if ratio >= 0.8 { return "太棒了！" }
        if ratio >= 0.6 { return "表现不错！" }
        if ratio >= 0.4 { return "继续努力！" }
        return "再接再厉！"
    }

    private func resultSubtitle(ratio: Double) -> String {
        if ratio >= 0.8 { return "你已经很好地掌握了这些知识点！" }
        if ratio >= 0.6 { return "基础扎实，还有提升空间！" }
        if ratio >= 0.4 { return "建议复习解析，查漏补缺！" }
        return "别灰心，每天坚持练习就会进步！"
    }

    private func resultStat(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    QuizView()
}
