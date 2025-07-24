//
//  CreateChecklistTasksSection.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/22/25.
//

import SwiftUI

struct CreateChecklistTasksSection: View {
    @Binding var tasks: [DraftTask]
    @State private var pendingTask: DraftTask? = nil
    
    var onAddTaskTapped: () -> Void
    
    var body: some View {
        Section {
            List {
                ForEach($tasks) { $task in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            TextField("Task", text: $task.title)
                                .onChange(of: task.title) { oldTitle, newTitle in
                                    if newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        tasks.removeAll { $0.id == task.id }
                                    }
                                }
                        }
                        
                        if !task.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            TextField("Description...", text: $task.description)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        } header: {
            HStack {
                Text("Tasks")
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

#Preview {
    CreateChecklistTasksSectionPreviewWrapper(tasks: [])
}

private struct CreateChecklistTasksSectionPreviewWrapper: View {
    @State var tasks: [DraftTask] = []
    
    var body: some View {
        CreateChecklistTasksSection(tasks: $tasks, onAddTaskTapped: {
            print("Stuff")
        })
    }
}
