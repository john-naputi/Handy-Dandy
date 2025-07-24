//
//  EditableTaskDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/29/25.
//

import SwiftUI

struct EditableTaskDescriptor: View {
    @Environment(\.dismiss) private var dismiss
    
    var intent: EditableTaskIntent
    @State var draftTask: Task
    
    init(intent: EditableTaskIntent) {
        self.intent = intent
        let task = intent.data
        let setupTask: Task
        if intent.mode == .create {
            setupTask = Task()
        } else {
            setupTask = intent.data
        }
        _draftTask = State(wrappedValue: setupTask)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                SectionHeader(title: "Name") {
                    TextField("Name", text: $draftTask.title)
                }
                
                SectionHeader(title: "Description") {
                    TextField("Description", text: $draftTask.taskDescription)
                }
            }
            .navigationTitle(headerTitle())
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if intent.mode == .create {
                            intent.delegate.onAddDone?(draftTask)
                        } else {
                            intent.delegate.onEditDone?(draftTask)
                        }
                        dismiss()
                    }
                    .disabled(draftTask.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        intent.delegate.onCancel?()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func headerTitle() -> String {
        if intent.mode == .create {
            return "New Task"
        }
        
        return "Edit Task"
    }
}

#Preview {
    let task = Task(title: "Task", description: "Description", isComplete: false, plan: nil, checklist: nil)
    let intent = EditableTaskIntent(data: task, mode: .update, delegate: TaskActionDelegate())
    EditableTasktDescriptorPreview(intent: intent)
}

fileprivate struct EditableTasktDescriptorPreview: View {
    var intent: EditableTaskIntent
    
    var body: some View {
        EditableTaskDescriptor(intent: intent)
    }
}
