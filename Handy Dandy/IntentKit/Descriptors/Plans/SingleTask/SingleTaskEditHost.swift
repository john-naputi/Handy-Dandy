//
//  SingleTaskEditHost.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/21/25.
//

import SwiftUI
import SwiftData

struct SingleTaskEditHost: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var store: SingleTaskStore?
    @State private var draft: DraftSingleTaskPlan?
    @State private var errorText: String?
    
    let planId: UUID
    
    var body: some View {
        Group {
            if let store, let shadow = store.shadow {
                EditableSingleTaskPlanView(
                    draft: DraftSingleTaskPlan(from: shadow),
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
            Text(errorText ?? "There was a problem trying to edit this single task.")
        }
    }
    
    private func bootstrap() async {
        do {
            var descriptor = FetchDescriptor<Plan>(
                predicate: #Predicate { $0.planId == planId }
            )
            descriptor.fetchLimit = 1
            
            guard let fresh = try modelContext.fetch(descriptor).first else {
                errorText = "Plan not found"
                return
            }
            
            if fresh.singleTask == nil {
                let task = SingleTask(plan: fresh)
                task.flavor = .from(planType: fresh.type)
                task.payload = .general(.init(text: fresh.title, notes: fresh.notes))
                fresh.singleTask = task
                try modelContext.save()
            }
            
            let localStore = SingleTaskStore(
                context: modelContext,
                planId: fresh.planId, makeShadow: SingleTaskShadowRegistry.make)
            
            store = localStore
            draft = localStore.makeDraft()
        } catch {
            errorText = error.localizedDescription
        }
    }
}

#Preview {
    SingleTaskEditHost(planId: .init())
}
