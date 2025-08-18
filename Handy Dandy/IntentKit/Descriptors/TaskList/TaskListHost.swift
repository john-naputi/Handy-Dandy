//
//  TaskListHost.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/19/25.
//

import SwiftUI
import SwiftData

@MainActor
struct TaskListHost: View {
    @Environment(\.modelContext) private var modelContext
    let plan: Plan
    
    @State private var store: TaskListStore?
    @State private var errorText: String?
    
    var body: some View {
        Group {
            if let store {
                TaskListContainer(store: store)
            } else {
                ProgressView("Loading...")
                    .task { await bootstrap() }
            }
        }
        .navigationTitle(plan.title.isEmpty ? "Checklist" : plan.title)
        .alert("Error", isPresented: .constant(errorText != nil)) {
            Button("OK") { errorText = nil }
        } message: { Text(errorText ?? "" )}
    }
    
    private func bootstrap() async {
        do {
            // Defensive refetch in case the plan was changed/deleted while navigating
            let target = plan.planId
            var fetchDescriptor = FetchDescriptor<Plan>()
            fetchDescriptor.predicate = #Predicate { $0.planId == target }
            fetchDescriptor.fetchLimit = 1
            guard let fetchedPlan = try modelContext.fetch(fetchDescriptor).first else {
                errorText = "Plan not found"
                return
            }
            
            let repository = TaskListBridge(context: modelContext)
            let list = try repository.fetchOrCreate(for: fetchedPlan)
            store = TaskListStore(context: modelContext, listID: list.taskListId)
        } catch {
            errorText = error.localizedDescription
        }
    }
}

#Preview {
    let plan = Plan(title: "Test Plan")
    TaskListHost(plan: plan)
}
