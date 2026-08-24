//
//  SettingsView.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import SwiftUI

/// 设置页
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
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
}

#Preview {
    SettingsView()
}