//
//  ReadonlyTaskListDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/1/25.
//

import SwiftUI

struct ViewableTaskListDescriptor: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var container: TaskContainer
    var delegate: ViewableTaskActionDelegate
    
    var body: some View {
        List {
            Section {
                ForEach(container.tasks) { task in
                    HStack {
                        Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                        VStack(alignment: .leading) {
                            Text(task.title)
                                .strikethrough(task.isComplete)
                            
                            
                            if !task.taskDescription.isEmpty {
                                Text(task.taskDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        delegate.onTaskComplete?(task)
                    }
                    .onLongPressGesture {
                        delegate.onBeginEdit?(task)
                    }
                }
                .onDelete { indexSet in
                    delegate.onDelete?(indexSet)
                }
            } header: {
                sectionHeader()
            }
        }
    }
    
    @ViewBuilder
    private func sectionHeader() -> some View {
        HStack {
            Text("Tasks")
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
            Button(action: {
                delegate.onBeginAdd?()
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

#Preview {
    let plan = Plan(
        title: "Weekly Shopping List",
        tasks: [
            ChecklistTask(title: "First Task", description: "First Description"),
            ChecklistTask(title: "Second Task", description: "Second Description"),
            ChecklistTask(title: "Third Task", description: "Third Description")
        ]
    )
    
    let delegate = ViewableTaskActionDelegate()
    
    ViewableTaskListDescriptor(container: plan, delegate: delegate)
}
