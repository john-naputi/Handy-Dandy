//
//  TaskFormView.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/27/25.
//

import SwiftUI

struct TaskFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var task: Task = Task()

    var onCreateDone: ((Task) -> Void)?
    var onEditDone: ((Task) -> Void)?
    
    var body: some View {
        NavigationStack {
            Form {
                SectionHeader(title: "Task Info") {
                    LimitedTextFieldSection(header: "Name", placeholder: "Buy eggs", text: $task.title)
                    LimitedTextFieldSection(header: "Description", placeholder: "2 dozen, not the 5 dozen", text: $task.taskDescription)
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let trimmedTitle = task.title.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedTitle.isEmpty else { return }
                        
                        let newTask = Task(title: trimmedTitle, description: task.taskDescription.trimmingCharacters(in: .whitespacesAndNewlines), plan: nil, checklist: nil)
                        onCreateDone?(newTask)
                        
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let task = Task()
    TaskFormSheetPreview(task: task)
}

fileprivate struct TaskFormSheetPreview: View {
    @State var task: Task
    
    var body: some View {
        TaskFormSheet(task: task, onCreateDone: { _ in
            // Nothing for now
        })
    }
}
