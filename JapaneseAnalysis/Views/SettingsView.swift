//
//  SettingsView.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import SwiftUI

/// 设置页
struct SettingsView: View {

    /// 订阅认证状态（单例，用 ObservedObject 以便登录状态变化时刷新 UI）
    @ObservedObject private var authService = AuthService.shared

    /// 是否正在发起登录
    @State private var isAuthenticating = false

    /// 登录相关错误提示
    @State private var authErrorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                accountSection

                Section("学习") {
                    LabeledContent("每日目标", value: "20 词")
                    LabeledContent("提醒时间", value: "20:00")
                    Toggle("每日提醒", isOn: .constant(true))
                }

                Section("关于") {
                    LabeledContent("版本", value: "1.0.0")
                }
            }
            .navigationTitle("设置")
        }
    }

    // MARK: - 账号区块

    @ViewBuilder
    private var accountSection: some View {
        Section("账号") {
            if authService.isLoggedIn {
                if let name = authService.memberDisplayName, !name.isEmpty {
                    LabeledContent("昵称", value: name)
                }
                if let email = authService.memberEmail, !email.isEmpty {
                    LabeledContent("邮箱", value: email)
                }

                LabeledContent("AI 服务", value: "已连接")

                Button(role: .destructive) {
                    Task { await signOut() }
                } label: {
                    Text("退出登录")
                }
            } else {
                Button {
                    Task { await signIn() }
                } label: {
                    HStack {
                        if isAuthenticating {
                            ProgressView()
                                .controlSize(.small)
                        }
                        Text(isAuthenticating ? "登录中..." : "登录 AI 账号")
                    }
                }
                .disabled(isAuthenticating)

                Text("登录后即可使用 AI 智能句子解析与每日挑战出题。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let authErrorMessage, !authErrorMessage.isEmpty {
                Text(authErrorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }

    // MARK: - 动作

    /// 发起 PKCE 登录（打开浏览器授权）
    private func signIn() async {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        authErrorMessage = nil

        do {
            try await authService.login()
        } catch let error as AuthError {
            // 用户主动取消不视为错误
            if case .authorizationCanceled = error {
                // 忽略
            } else {
                authErrorMessage = error.errorDescription ?? "登录失败"
            }
        } catch {
            authErrorMessage = error.localizedDescription
        }

        isAuthenticating = false
    }

    /// 退出登录
    private func signOut() async {
        await authService.logout()
    }
}

#Preview {
    SettingsView()
}