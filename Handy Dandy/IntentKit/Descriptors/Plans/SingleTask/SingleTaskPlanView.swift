//
//  SingleTaskPlanView.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/21/25.
//

import SwiftUI

struct SingleTaskPlanView: View {
    let task: DraftSingleTaskPlan
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(task.isDone ? .green : .primary)
                    .accessibilityHidden(true)
                
                Text(task.title.isEmpty ? "Untitled Task" : task.title)
                    .strikethrough(task.isDone)
                    .foregroundStyle(task.isDone ? .secondary : .primary)
            }
            .padding()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(task.isDone ? "Untitled task" : task.title)
        .accessibilityValue(task.isDone ? "Completed" : "Incomplete")
    }
}

#Preview {
    SingleTaskPlanView(task: .init(id: UUID(), title: "First Task"))
}
