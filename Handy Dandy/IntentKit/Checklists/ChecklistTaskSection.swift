//
//  CreateChecklistTasksSection.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/22/25.
//

import SwiftUI

struct ChecklistTaskSection: View {
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var checklist: Checklist
    @Binding var mode: ChecklistFormMode
    
//    @ObservedObject var state: ChecklistFormState
    var onAddTaskTapped: () -> Void
    @FocusState var focusTaskId: UUID?
    
    var body: some View {
        Section {
            ForEach($checklist.tasks) { task in
                VStack(alignment: .leading, spacing: 8) {
                    if !mode.isEditable {
                        readOnlyTaskRow(task: task.wrappedValue)
                    } else {
                        editableTaskRow(task)
                    }
                }
                .padding(.vertical, 4)
            }
        } header: {
            HStack {
                Text("Tasks")
                
                if mode.isEditable {
                    Spacer()
                    Button(action: {
                        onAddTaskTapped()
                    }) {
                        Label("Add Task", systemImage: "plus.circle")
                            .foregroundStyle(Color(.blue))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Add Task")
                }
            }
        }
    }
    
    @ViewBuilder
    func readOnlyTaskRow(task: Task) -> some View {
        VStack(alignment: .leading) {
            Text(task.title)
            
            if !task.taskDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(task.taskDescription)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    func editableTaskRow(_ task: Binding<Task>) -> some View {
        VStack {
            TextField("Task", text: task.title)
                .focused($focusTaskId, equals: task.id)
                .onChange(of: focusTaskId) { oldFocus, newFocus in
                    if let currentTask = checklist.tasks.first(where: { $0.id == oldFocus }) {
                        if currentTask.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            checklist.tasks.removeAll { $0.id == oldFocus }
                            modelContext.delete(currentTask)
//                            checklist.plan?.tasks.removeAll(where: { $0.id == oldFocus })
                        }
                    }
                }
            
            let description = task.wrappedValue.taskDescription
            if !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                TextField("Description...", text: task.taskDescription)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    ChecklistTaskSectionPreview()
}

private struct ChecklistTaskSectionPreview: View {
    @Bindable var checklist: Checklist = Checklist(title: "Awesome checklist", checklistDescription: "Just a checklist")
    @State var mode: ChecklistFormMode = .view
    
    var body: some View {
        ChecklistTaskSection(checklist: checklist, mode: $mode) {
            // Nothing to do
        }
    }
}
