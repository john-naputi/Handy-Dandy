//
//  TaskListView.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/26/25.
//

import SwiftUI

struct TaskListView: View {
    @Environment(\.colorScheme) private var colorScheme
    var tasks: [Task]
    @Binding var showCreateTaskSheet: Bool
    
    var onEditTask: ((Task) -> Void)? = nil
    var onDeleteTask: ((IndexSet) -> Void)? = nil
    var onTaskCompleted: (() -> Void)? = nil
    
    var body: some View {
        List {
            Section {
                ForEach(tasks) { task in
                    TaskRow(
                        task: task,
                        onEditTask: { taskToEdit in
                            onEditTask?(taskToEdit)
                        },
                        onTaskCompleted: {
                            onTaskCompleted?()
                        }
                    )
                }
                .onDelete { indexToRemove in
                    onDeleteTask?(indexToRemove)
                }
            } header: {
                sectionHeader()
            }
        }
    }
    
    @ViewBuilder
    func sectionHeader() -> some View {
        HStack {
            Text("Tasks")
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
            Button(action: {
                showCreateTaskSheet.toggle()
            }) {
                Label("Add Task", systemImage: "plus.circle")
            }
            .font(.headline)
            .buttonStyle(.borderless)
            .tint(colorScheme == .dark ? .green : .primary)
            .accessibilityLabel("Add Task")
        }
    }
}

//#Preview {
//    TaskListView()
//}
