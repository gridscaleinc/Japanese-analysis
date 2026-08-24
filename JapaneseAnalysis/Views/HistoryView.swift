//
//  HistoryView.swift
//  JapaneseAnalysis
//
//  Created by 田芳 on R 8/08/06.
//

import SwiftUI

/// 历史页
struct HistoryView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "暂无学习历史",
                systemImage: "clock.arrow.circlepath",
                description: Text("开始学习后，你的浏览记录会显示在这里")
            )
            .navigationTitle("历史")
        }
    }
}

#Preview {
    HistoryView()
}