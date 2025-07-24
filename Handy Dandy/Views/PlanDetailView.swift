//
//  PlanDetailView.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/21/25.
//

import SwiftUI

struct PlanDetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var plan: Plan
    @State private var showCreateTaskSheet = false
    @State private var showEditTaskSheet = false
    @State private var taskToEdit: Task? = nil
    
    var body: some View {
        VStack {
            ChecklistsSection(plan: plan)
            TaskListView(
                tasks: plan.tasks,
                showCreateTaskSheet: $showCreateTaskSheet,
                onEditTask: { task in
                    taskToEdit = task
                    showEditTaskSheet.toggle()
                },
                onDeleteTask: { indexSet in
                    for index in indexSet {
                        let task = plan.tasks[index]
                        plan.tasks.remove(at: index)
                        modelContext.delete(task)
                        try? modelContext.save()
                    }
                },
                onTaskCompleted: {
                    try? modelContext.save()
                }
            )
        }
        .sheet(isPresented: $showCreateTaskSheet) {
            TaskFormSheet(onCreateDone: { newTask in
                newTask.plan = plan
                modelContext.insert(newTask)
                plan.tasks.append(newTask)
            })
        }
        .sheet(item: $taskToEdit) { task in
            TaskFormSheet(task: task, onEditDone: { _ in
                taskToEdit = nil
            })
        }
    }
}

#Preview {
    let samplePlan = Plan(title: "Weekend Errands")
    
    PlanDetailView(plan: samplePlan)
}
