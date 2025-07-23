//
//  CreateChecklistTasksSection.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/22/25.
//

import SwiftUI

struct CreateChecklistTasksSection: View {
    @Binding var tasks: [TaskDraft]
    
    @FocusState private var focusedTaskID: UUID?
    
    var body: some View {
        Section(header: Text("Tasks")) {
            ForEach($tasks) { $task in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        TextField("Task", text: $task.title)
                            .focused($focusedTaskID, equals: $task.id)
                            .onChange(of: task.title) { oldTitle, newTitle in
                                if newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    tasks.removeAll { $0.id == task.id }
                                }
                            }
                        
                        Button(action: {
                            task.showDescription.toggle()
                        }) {
                            Image(systemName: task.showDescription ? "minus.circle" : "plus.circle")
                                .foregroundStyle(Color(.blue))
                        }
                    }
                    
                    if task.showDescription || !task.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        TextField("Description...", text: $task.description)
                            .textFieldStyle(.roundedBorder)
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.vertical, 4)
                .onChange(of: focusedTaskID) { oldFocus, newFocus in
                    guard let oldFocus else {
                        return
                    }
                    
                    if let index = tasks.firstIndex(where: { $0.id == oldFocus }) {
                        if tasks[index].description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            tasks[index].showDescription = false
                        }
                    }
                }
            }
            Button(action: {
                let newTask = TaskDraft(title: "", description: "")
                tasks.append(newTask)
                focusedTaskID = newTask.id
            }, label: {
                Label("Add Task", systemImage: "plus")
                    .foregroundColor(.blue)
            })
        }
    }
}

#Preview {
    CreateChecklistTasksSectionPreviewWrapper(tasks: [])
}

private struct CreateChecklistTasksSectionPreviewWrapper: View {
    @State var tasks: [TaskDraft] = []
    
    var body: some View {
        CreateChecklistTasksSection(tasks: $tasks)
    }
}
