//
//  SingleTaskContainer.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/21/25.
//

import SwiftUI
import SwiftData

struct SingleTaskContainer: View {
    @Bindable var store: SingleTaskStore
    @State private var draft: DraftSingleTaskPlan?
    
    var body: some View {
        Group {
            if let shadow = store.shadow {
                SingleTaskPlanView(task: .init(id: shadow.id, title: shadow.title, isDone: shadow.isDone))
                    .navigationTitle("Task")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(shadow.isDone ? "Mark Not Done" : "Mark Done") {
                                store.toggle()
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Edit") {
                                draft = DraftSingleTaskPlan(id: shadow.id, title: shadow.title, isDone: shadow.isDone)
                            }
                            .accessibilityLabel("Edit task")
                            .accessibilityHint("Opens the editor to rename or toggle the task's completion")
                        }
                    }
            } else {
                ProgressView("Loading...")
            }
        }
        .sheet(item: $draft) { planDraft in
            EditableSingleTaskPlanView(draft: planDraft, onCancel: { draft = nil }, onSave: { newDraft in
                draft = nil
                store.applyDraft(newDraft)
            })
        }
    }
}

#Preview {
    let schema = Schema([SingleTask.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = ModelContext(container)
    
    let task = SingleTask(title: "Drink Water")
    context.insert(task)
    try! context.save()
    
    let store = SingleTaskStore(context: context, taskID: task.uid)
    
    return SingleTaskContainer(store: store)
}
