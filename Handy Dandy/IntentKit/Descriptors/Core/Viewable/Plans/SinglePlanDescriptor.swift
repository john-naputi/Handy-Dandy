//
//  SinglePlanDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/30/25.
//

import SwiftUI
import Foundation
import SwiftData

struct SinglePlanDescriptor: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var showCreateTaskSheet = false
    @State private var taskToEdit: ChecklistTask? = nil
    
    var plan: Plan
    
    var body: some View {
        NavigationStack {
            VStack {
                ViewableMultiChecklistDescriptor(plan: plan)
                TaskContainerDelegateDescriptor(container: plan)
            }
            .sheet(isPresented: $showCreateTaskSheet) {
                let intent = makeEditableIntent(mode: .create)
                EditableTaskDescriptor(intent: intent)
            }
        }
    }
    
    private func makeEditableIntent(mode: EditMode) -> EditableTaskIntent {
        let task = (mode == .create) ? ChecklistTask.emptyDraft() : (taskToEdit ??  ChecklistTask.emptyDraft())
        return EditableTaskIntent(
            data: task,
            mode: mode,
            delegate: TaskActionDelegate(
                onEditDone: onEditDone,
                onAddDone: onAddDone,
                onCancel: onCancel
            )
        )
    }
    
    private func onTaskCompleted(task: ChecklistTask) {
        guard let index = plan.tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        
        plan.tasks[index].isComplete.toggle()
        try? modelContext.save()
    }
    
    private func onAddDone(task: ChecklistTask) {
        plan.tasks.append(task)
        modelContext.insert(task)
        try? modelContext.save()
    }
    
    private func onBeginAdd() {
        showCreateTaskSheet.toggle()
    }
    
    private func onBeginEdit(task: ChecklistTask) {
        guard let index = plan.tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        
        taskToEdit = plan.tasks[index]
    }
    
    private func onEditDone(task: ChecklistTask) {
        if let index = plan.tasks.firstIndex(where: { $0.id == task.id }) {
            plan.tasks[index].title = task.title
            plan.tasks[index].taskDescription = task.taskDescription
            try? modelContext.save()
        }
        taskToEdit = nil
    }
    
    private func cleanup(_ task: ChecklistTask) {
        task.title = task.title.trimmingCharacters(in: .whitespacesAndNewlines)
        task.taskDescription = task.taskDescription.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func onCancel() {
        taskToEdit = nil
    }
    
    private func onDelete(indexSet: IndexSet) {
        for index in indexSet {
            let task = plan.tasks[index]
            plan.tasks.remove(at: index)
            modelContext.delete(task)
            try? modelContext.save()
        }
    }
}

#Preview {
    let plan = Plan(title: "Test Plan", description: "Description", planDate: .now)
    SinglePlanDescriptor(plan: plan)
}
