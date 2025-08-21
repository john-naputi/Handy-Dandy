//
//  TaskListSummaryView.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/20/25.
//

import SwiftUI

struct TaskListSummaryView: View {
    let percentText: String
    let progress: Double
    let detailText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(percentText).font(.headline)
            ProgressView(value: progress)
                .accessibilityLabel("Task Completion Progress")
                .accessibilityValue("\(Int((progress).rounded(.toNearestOrEven) * 100)) percent completed")
            Text(detailText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(alignment: .leading)
    }
}

#Preview {
    TaskListSummaryView(percentText: "50%", progress: Double(0.5), detailText: "Almost there!!!")
}
