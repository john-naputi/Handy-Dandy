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
    let rowContent: (TaskListItemShadow) -> AnyView
    
    var onToggle: (UUID) -> Void = { _ in }
    var onDelete: (UUID) -> Void = { _ in }
    var onClearCompleted: () -> Void = {}
    var onEdit: (TaskListItemShadow) -> Void = { _ in }
    
    private var todos: [TaskListItemShadow] {
        shadow.tasks.filter { !$0.isDone }
    }
    
    private var dones: [TaskListItemShadow] {
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
    
    init(
        shadow: TaskListShadow,
        onToggle: @escaping (UUID) -> Void = { _ in },
        onDelete: @escaping (UUID) -> Void = { _ in },
        onClearCompleted: @escaping () -> Void = {},
        onEdit: @escaping (TaskListItemShadow) -> Void = { _ in },
        @ViewBuilder rowContent: @escaping (TaskListItemShadow) -> some View
    ) {
        self.shadow = shadow
        self.onToggle = onToggle
        self.onDelete = onDelete
        self.onClearCompleted = onClearCompleted
        self.onEdit = onEdit
        self.rowContent = {
            AnyView(
                rowContent($0)
                    .accessibilityElement(children: .combine)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            )
        }
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(shadow.progressPercentText).font(.headline)
                    ProgressView(value: shadow.progress)
                        .accessibilityLabel("Task Completion Progress")
                        .accessibilityValue("\(Int((shadow.progress).rounded(.toNearestOrEven) * 100)) percent")
                        .accessibilityHint("Shows the overall completion progress of all tasks in the list.")
                    Text(shadow.progressText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(alignment: .leading)
            } header: {
                Text("Summary")
                    .textCase(nil)
                    .accessibilityAddTraits(.isHeader)
            }
            
            if shadow.tasks.isEmpty {
                Section {
                    Text("No Tasks Have Been Created")
                        .accessibilityLabel("No Tasks")
                        .accessibilityHint("Use the Add button to create your first task.")
                }
            } else {
                if !todos.isEmpty {
                    Section {
                        ForEach(todos) { item in
                            rowContent(item)
                                .swipeActions {
                                    Button { onToggle(item.id) } label: { Label("Done", systemImage: "checkmark") }
                                    Button(role: .destructive) { onDelete(item.id) } label: { Label("Delete", systemImage: "trash") }
                                }
                                .contextMenu {
                                    Button { onEdit(item) } label: { Label("Edit", systemImage: "pencil") }
                                }
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading).combined(with: .opacity),
                                    removal:   .move(edge: .trailing).combined(with: .opacity)
                                ))
                                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                        }
                    } header: {
                        Text("Remaining Tasks")
                            .textCase(nil)
                            .accessibilityAddTraits(.isHeader)
                    }
                }
                
                if !dones.isEmpty {
                    Section {
                        ForEach(dones) { item in
                            rowContent(item)
                                .swipeActions {
                                    Button {
                                        onToggle(item.id)
                                    } label: {
                                        Label("Undo", systemImage: "arrow.uturn.left")
                                    }
                                    Button(role: .destructive) {
                                        onDelete(item.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .contextMenu {
                                    Button {
                                        onEdit(item)
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                }
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
    
    @ViewBuilder
    private func completedSectionHeader() -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 8) {
                Text("Completed")
                    .textCase(nil)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer(minLength: 8)
                
                Button(role: .destructive) {
                    onClearCompleted()
                } label: {
                    Text("Clear Completed")
                        .lineLimit(2)
                        .accessibilityLabel("Clear completed")
                        .accessibilityHint("Removes all completed tasks from this list.")
                }
                .accessibilityLabel("Clear completed tasks")
                .accessibilityHint("Removes all completed tasks from this list")
            }
        } else {
            HStack(alignment: .firstTextBaseline) {
                Text("Completed")
                    .textCase(nil)
                    .accessibilityAddTraits(.isHeader)
                
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
    let items: [TaskListItemShadow] = [
        .init(payload: .general(.init(id: UUID(), text: "Brush my teeth", isDone: true))),
        .init(payload: .general(.init(id: UUID(), text: "Eat breakfast", isDone: false)))
    ]
    let shadow = TaskListShadow(id: UUID(), title: "The Shadow", tasks: items)
    TaskListReadonlyView(
        shadow: shadow,
        rowContent: { item in
            item.fold(
                general: { AnyView(TaskRow(item: $0) )},
                shopping: { _ in AnyView(Text("Shopping Row Coming Soon!!!") )}
            )
        })
}
