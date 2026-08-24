//
//  HomeView.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import SwiftUI

/// 首页 - 日语学习概览
struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // 学习统计卡片
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(title: "今日学习", value: "24", unit: "词", icon: "book.fill", color: .blue)
                        StatCard(title: "累计词汇", value: "1,286", unit: "词", icon: "character.book.closed.fill", color: .green)
                        StatCard(title: "连续学习", value: "12", unit: "天", icon: "flame.fill", color: .orange)
                        StatCard(title: "语法掌握", value: "86", unit: "%", icon: "checkmark.seal.fill", color: .purple)
                    }

                    // 功能入口
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        MenuTile(title: "单词学习", icon: "text.book.closed", color: .blue)
                        MenuTile(title: "语法解析", icon: "text.bubble", color: .orange)
                        NavigationLink {
                            AnalysisView()
                        } label: {
                            MenuTile(title: "句子分析", icon: "doc.text.magnifyingglass", color: .green)
                        }
                        .buttonStyle(.plain)
                        MenuTile(title: "听力训练", icon: "headphones", color: .red)
                        MenuTile(title: "阅读练习", icon: "book", color: .purple)
                        NavigationLink {
                            QuizView()
                        } label: {
                            MenuTile(title: "每日挑战", icon: "pencil.and.list.clipboard", color: .teal)
                        }
                        .buttonStyle(.plain)
                    }

                    // 每日一句
                    DailySentenceCard(
                        japanese: "継続は力なり",
                        kana: "けいぞくは ちからなり",
                        chinese: "坚持就是力量",
                        attribution: "日本のことわざ"
                    )
                }
                .padding()
            }
            .navigationTitle("日本語学習")
        }
    }
}

// MARK: - 学习统计卡片

private struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 功能入口

private struct MenuTile: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.12))
                .clipShape(Circle())
            Text(title)
                .font(.caption)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 每日一句

private struct DailySentenceCard: View {
    let japanese: String
    let kana: String
    let chinese: String
    let attribution: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📖 每日一句")
                    .font(.headline)
                Spacer()
            }
            VStack(spacing: 8) {
                Text(japanese)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                Text(kana)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Divider()
                Text(chinese)
                    .font(.body)
            }
            .frame(maxWidth: .infinity)
            HStack {
                Spacer()
                Text(attribution)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    HomeView()
}