//
//  TaskListEditHost.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/21/25.
//

import SwiftUI
import SwiftData

struct TaskListEditHost: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var store: TaskListStore?
    @State private var errorText: String?
    
    let plan: Plan
    
    var body: some View {
        Group {
            if let store, let shadow = store.shadow {
                EditableTaskListDescriptor(
                    initial: DraftTaskList(from: shadow),
                    onCancel: { dismiss() },
                    onSave: { draft in
                        store.applyDraft(draft)
                        dismiss()
                    }
                )
            } else {
                ProgressView("Loading...")
                    .task { await bootstrap() }
            }
        }
        .alert("Error", isPresented: .constant(errorText != nil)) {
            Button("OK") {
                errorText = nil
                dismiss()
            }
        } message: {
            Text(errorText ?? "There was a problem when trying to edit this plan.")
        }
    }
    
    private func bootstrap() async {
        do {
            let target = plan.planId
            var descriptor = FetchDescriptor<Plan>(
                predicate: #Predicate { $0.planId == target },
                sortBy: []
            )
            descriptor.fetchLimit = 1
            
            guard let fetched = try modelContext.fetch(descriptor).first else {
                errorText = "Plan not found"
                return
            }
            
            let bridge = TaskListBridge(context: modelContext)
            let list = try bridge.fetchOrCreate(for: fetched)
            store = TaskListStore(context: modelContext, listID: list.taskListId)
        } catch {
            errorText = error.localizedDescription
        }
    }
}

#Preview {
    TaskListEditHost(plan: .init(title: "Test Plan"))
}
