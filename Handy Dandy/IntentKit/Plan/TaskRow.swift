//
//  TaskRow.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/26/25.
//

import SwiftUI

struct TaskRow: View {
    @Bindable var task: Task
    @State var showEditTaskSheet: Bool = false
    
    let onEditTask: (Task) -> Void
    let onTaskCompleted: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                .onTapGesture {
                    task.isComplete.toggle()
                }
            
            VStack(alignment: .leading) {
                Text(task.title)
                    .strikethrough(task.isComplete)
                
                let description = task.taskDescription
                if !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            task.isComplete.toggle()
            onTaskCompleted()
        }
        .onLongPressGesture {
            onEditTask(task)
        }
    }
}

#Preview {
    let task = Task(title: "Buy milk", description: "From the dairy section", isComplete: false, plan: nil, checklist: nil)
    TaskRowPreview(task: task)
}

fileprivate struct TaskRowPreview: View {
    @State var task: Task
    
    var body: some View {
        TaskRow(
            task: task,
            onEditTask: { task in
                print(task.title)
            },
            onTaskCompleted: {}
        )
    }
}
