//
//  TaskListDetailView.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/18/25.
//

import SwiftUI
import SwiftData

struct TaskListReadonlyView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    let shadow: TaskListShadow
    var onToggle: (UUID) -> Void = { _ in }
    var onDelete: (UUID) -> Void = { _ in }
    var onClearCompleted: () -> Void = {}
    var onEdit: (TaskItemShadow) -> Void = { _ in }
    
    private var todos: [TaskItemShadow] {
        shadow.tasks.filter { !$0.isDone }
    }
    
    private var dones: [TaskItemShadow] {
        shadow.tasks.filter { $0.isDone }
    }
    
    enum Sheet: Identifiable {
        case add, edit(DraftTaskItem)
        
        var id: String {
            switch self {
            case .add: return "add"
            case .edit(let taskItem): return "edit-task-\(taskItem.id)"
            }
        }
    }
    
    var body: some View {
        List {
            header()
            if shadow.tasks.isEmpty {
                Section {
                    Text("No Tasks Have Been Created")
                        .accessibilityLabel("Add a Task Using the Add Task Button.")
                }
            } else {
                if !todos.isEmpty {
                    Section {
                        ForEach(todos) { item in
                            TaskRow(
                                item: item,
                                onToggle: { onToggle(item.id) },
                                onDelete: { onDelete(item.id) },
                                onEdit: { onEdit(item) }
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                            .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                        }
                    } header: {
                        Text("Remaining Tasks")
                            .textCase(nil)
                    }
                }
                
                if !dones.isEmpty {
                    Section {
                        ForEach(dones) { item in
                            TaskRow(
                                item: item,
                                onToggle: { onToggle(item.id) },
                                onDelete: { onDelete(item.id) },
                                onEdit: { onEdit(item) }
                            )
                            .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                        }
                    } header: {
                        completedSectionHeader()
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .animation(.default, value: shadow.tasks.map(\.id))
    }
    
    private func header() -> some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text(shadow.progressPercentText).font(.headline)
                ProgressView(value: shadow.progress)
                    .accessibilityLabel("Task Completion Progress")
                    .accessibilityValue("\(Int((shadow.progress).rounded(.toNearestOrEven) * 100)) percent completed")
                Text(shadow.progressText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(alignment: .leading)
        } header: {
            Text("Summary").textCase(nil)
        }
    }
    
    @ViewBuilder
    private func completedSectionHeader() -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 8) {
                Text("Completed").textCase(nil)
                Spacer(minLength: 8)
                Button(role: .destructive) {
                    onClearCompleted()
                } label: {
                    Text("Clear Completed")
                        .lineLimit(2)
                }
                .accessibilityLabel("Clear completed tasks")
                .accessibilityHint("Removes all completed tasks from this list")
            }
        } else {
            HStack(alignment: .firstTextBaseline) {
                Text("Completed").textCase(nil)
                Spacer(minLength: 8)
                Button(role: .destructive) {
                    onClearCompleted()
                } label: {
                    Text("Clear Completed")
                        .lineLimit(1)
                }
                .accessibilityLabel("Clear completed tasks")
                .accessibilityHint("Removes all completed tasks from this list")
            }
        }
    }
}

#Preview {
    let shadow = TaskListShadow(id: UUID(), title: "The Shadow", tasks: [
        TaskItemShadow(id: UUID(), text: "Brush my teeth", isDone: false),
        TaskItemShadow(id: UUID(), text: "Eat breakfast", isDone: true),
        TaskItemShadow(id: UUID(), text: "Speak of glory", isDone: true),
        TaskItemShadow(id: UUID(), text: "Get to work", isDone: true)
    ])
    TaskListReadonlyView(shadow: shadow)
}
