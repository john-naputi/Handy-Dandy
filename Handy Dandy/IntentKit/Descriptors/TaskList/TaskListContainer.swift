//
//  TaskListContainer.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/18/25.
//

import SwiftUI
import SwiftData
import Observation

struct TaskListContainer: View {
    @Bindable var store: TaskListStore
    @State private var draftTaskList: DraftTaskList?
    @State private var renameTarget: DraftTaskItem?
    @State private var lastCleared: [TaskListStore.RemovedTaskSnapshot] = []
    @State private var showUndoToast: Bool = false
    @State private var dismissTask: Task<Void, Never>?
    @State private var toastGeneration = 0
    
    var body: some View {
        NavigationStack {
            Group {
                if let shadow = store.shadow {
                    TaskListReadonlyView(
                        shadow: shadow,
                        onToggle: { store.toggleTask($0) },
                        onDelete: { store.deleteTask($0) },
                        onClearCompleted: {
                            let snapshots = store.clearCompletedReturningSnapshots()
                            triggerUndoToast(for: snapshots)
                        },
                        onEdit: {
                            renameTarget = .init(from: $0)
                        }
                    )
                    .navigationTitle(shadow.title)
                    .navigationBarTitleDisplayMode(.inline)
                } else {
                    ProgressView("Loading...")
                }
            }
            .toolbar {
                if let shadow = store.shadow {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Edit") {
                            draftTaskList = DraftTaskList(from: shadow)
                        }
                    }
                }
            }
            .sheet(item: $draftTaskList) { draft in
                EditableTaskListDescriptor(initial: draft, onCancel: {
                    draftTaskList = nil
                }, onSave: { newDraft in
                    draftTaskList = nil
                    applyChanges(from: newDraft)
                })
            }
            .sheet(item: $renameTarget) { target in
                RenameTaskSheet(
                    initial: target.text,
                    onCancel: { renameTarget = nil },
                    onSave: { newText in
                        store.editTask(target.id, text: newText)
                        renameTarget = nil
                    }
                )
            }
            .safeAreaInset(edge: .bottom) {
                if showUndoToast, !lastCleared.isEmpty {
                    undoToast(
                        count: lastCleared.count,
                        undo: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                store.restore(lastCleared)
                                showUndoToast = false
                                lastCleared = []
                            }
                        },
                        dismiss: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                showUndoToast = false
                                lastCleared = []
                            }
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
    
    // MARK: Internal helpers
    private func applyChanges(from draft: DraftTaskList) {
        store.applyDraft(draft)
    }
    
    private func triggerUndoToast(for snapshots: [TaskListStore.RemovedTaskSnapshot]) {
        guard !snapshots.isEmpty else { return }
        lastCleared = snapshots
        dismissTask?.cancel()
        toastGeneration &+= 1
        let generation = toastGeneration
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
            showUndoToast = true
        }
        
        // Auto-dismiss after 4 seconds
        dismissTask = Task {
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            // Check if this task is still the active one
            guard generation == toastGeneration else { return } // It is superseded
            await MainActor.run {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                    showUndoToast = false
                    lastCleared = []
                }
            }
        }
    }
    
    private func undoToast(count: Int, undo: @escaping () -> Void, dismiss: @escaping () -> Void) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .imageScale(.large)
            Text(count == 1 ? "Cleared 1 Completed Task" : "Cleared \(count) Completed Tasks")
                .lineLimit(1)
            Spacer()
            Button("Undo") {
                dismissTask?.cancel()
                toastGeneration &+= 1
                undo()
            }
            .bold()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.horizontal)
        .onTapGesture {
            dismissTask?.cancel()
            toastGeneration &+= 1
            dismiss()
        }
    }
}

#Preview {
    TaskListContainerPreview()
}

fileprivate struct TaskListContainerPreview: View {
    @State var store: TaskListStore
    
    init() {
        let schema = Schema([TaskList.self, TaskItem.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)
        
        let list = TaskList(title: "REI Run", tasks: [
            .init(text: "Buy gels", sortIndex: 0),
            .init(text: "Charge watch", isDone: true, sortIndex: 1),
            .init(text: "Lay out kit", sortIndex: 2)
        ])
        
        context.insert(list)
        try! context.save()
        
        _store = State(initialValue: TaskListStore(context: context, listID: list.taskListId))
    }
    
    var body: some View {
        TaskListContainer(store: store)
    }
}
