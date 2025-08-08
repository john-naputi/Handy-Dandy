//
//  TaskRowDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/1/25.
//

import Foundation
import SwiftUI

struct TaskRowDescriptor: View {
    var task: ChecklistTask
    @State var showEditSheet: Bool = false
    
    let onEditTask: (ChecklistTask) -> Void
    let onTaskCompleted: (UUID) -> Void
    
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
            onTaskCompleted(task.id)
        }
        .onLongPressGesture {
            onEditTask(task)
        }
    }
}

#Preview {
    let task = ChecklistTask(title: "First Task", description: "First Description")
    TaskRowDescriptor(task: task, onEditTask: { _ in }, onTaskCompleted: { _ in })
}
