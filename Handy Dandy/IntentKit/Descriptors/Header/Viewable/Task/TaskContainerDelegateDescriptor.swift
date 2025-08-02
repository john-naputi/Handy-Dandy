//
//  TaskContainer.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/2/25.
//

import SwiftUI

struct TaskContainerDelegateDescriptor<TContainer: TaskContainer>: View {
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var container: TContainer
    
    @State private var showCreateTaskSheet = false
    @State private var showEditTaskSheet = false
    @State private var taskToEdit: Task?
    
    var body: some View {
        NavigationStack {
            Form {
                let delegate = ViewableTaskActionDelegate(
                    onBeginEdit: onBeginEdit,
                    onTaskComplete: onTaskCompleted,
                    onBeginAdd: onBeginAdd,
                    onDelete: onDelete,
                )
                
                ViewableTaskListDescriptor(container: container, delegate: delegate)
            }
        }
        .sheet(isPresented: $showCreateTaskSheet) {
            let intent = makeEditableIntent(mode: .create)
            EditableTaskDescriptor(intent: intent)
        }
        .sheet(item: $taskToEdit) { task in
            let intent = makeEditableIntent(task: task, mode: .update)
            EditableTaskDescriptor(intent: intent)
        }
    }
    
    private func makeEditableIntent(task: Task = Task.emptyDraft(), mode: EditMode) -> EditableTaskIntent {
        EditableTaskIntent(data: task, mode: mode, delegate: TaskActionDelegate(
            onEditDone: onEditDone,
            onAddDone: onAddDone,
            onCancel: onCancel,
        ))
    }
    
    private func onAddDone(task: Task) {
        container.addTask(task)
        modelContext.insert(task)
        try? modelContext.save()
    }
    
    private func onEditDone(task: Task) {
        if let index = container.tasks.firstIndex(where: { $0.id == task.id }) {
            container.tasks[index].title = task.title
            container.tasks[index].taskDescription = task.taskDescription
            try? modelContext.save()
        }
        
        taskToEdit = nil
    }
    
    private func onBeginEdit(task: Task) {
        taskToEdit = task
    }
    
    private func onTaskCompleted(task: Task) {
        guard let index = container.tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        
        container.tasks[index].isComplete.toggle()
        try? modelContext.save()
    }
    
    private func onBeginAdd() {
        showCreateTaskSheet.toggle()
    }
    
    private func onDelete(indexSet: IndexSet) {
        if indexSet.isEmpty {
            return
        }
        
        for index in indexSet {
            let task = container.tasks[index]
            container.removeTask(task)
            modelContext.delete(task)
        }
        
        try? modelContext.save()
    }
    
    private func onCancel() {
        taskToEdit = nil
    }
}

#Preview {
    let plan = Plan(title: "Plan", description: "Description", planDate: .now, tasks: [
        Task(title: "First", description: "First description"),
        Task(title: "Second", description: "Second description")
    ])
    TaskContainerDelegateDescriptor(container: plan)
}
