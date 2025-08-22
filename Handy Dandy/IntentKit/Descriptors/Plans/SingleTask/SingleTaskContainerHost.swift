//
//  SingleTaskContainerHost.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/21/25.
//

import SwiftUI
import SwiftData

struct SingleTaskContainerHost: View {
    @Environment(\.modelContext) private var modelContext
    @State private var store: SingleTaskStore?
    @State private var errorText: String?
    
    let plan: Plan
    
    var body: some View {
        Group {
            if let store, let shadow = store.shadow {
                SingleTaskReadonlyView(
                    shadow: shadow,
                    onToggleDone: {},
                    onEditTitle: {},
                    onEditNotes: {},
                    onSetDue: {},
                    onClearDue: {}
                )
            } else {
                ProgressView("Loading...").task {
                    await bootstrap()
                }
            }
        }
        .navigationTitle(plan.title.isEmpty ? "Task" : plan.title)
        .alert("Error", isPresented: .constant(errorText != nil)) {
            Button("OK") {
                errorText = nil
            }
        } message: {
            Text(errorText ?? "There was a problem trying to edit this task.")
        }
    }
    
    private func bootstrap() async {
        do {
            let id = plan.planId
            var descriptor = FetchDescriptor<Plan>(
                predicate: #Predicate { $0.planId == id}
            )
            descriptor.fetchLimit = 1
            guard let fresh = try modelContext.fetch(descriptor).first else {
                errorText = "Plan not found"
                return
            }
            
            if fresh.singleTask == nil {
                fresh.singleTask = SingleTask(plan: fresh)
                try modelContext.save()
            }
            
            store = SingleTaskStore(context: modelContext, planId: fresh.planId)
        } catch {
            errorText = error.localizedDescription
        }
    }
}

#Preview {
    SingleTaskContainerHost(plan: .init(title: "Awesome Plan"))
}
