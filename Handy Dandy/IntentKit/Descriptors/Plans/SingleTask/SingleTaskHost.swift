//
//  SingleTaskContainerHost.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/21/25.
//

import SwiftUI
import SwiftData

enum SingleTaskSheetRoute: Identifiable {
    case editAll(DraftSingleTaskPlan)
    case editNotes(DraftSingleTaskPlan)
    case editDue(DraftSingleTaskPlan)
    
    var id: String {
        switch self {
        case .editAll: return "editAll"
        case .editNotes: return "editNotes"
        case .editDue: return "editDue"
        }
    }
}

struct SingleTaskHost: View {
    @Environment(\.modelContext) private var modelContext
    @State private var store: SingleTaskStore?
    @State private var errorText: String?
    @State private var activeSheet: SingleTaskSheetRoute?
    
    let plan: Plan
    
    var body: some View {
        Group {
            if let store, let shadow = store.shadow {
                SingleTaskReadonlyView(
                    shadow: shadow,
                    onToggleDone: {
                        store.toggle()
                    },
                    onEditTitle: {
                        activeSheet = store.makeDraft().map(SingleTaskSheetRoute.editAll)
                    },
                    onEditNotes: {
                        activeSheet = store.makeDraft().map(SingleTaskSheetRoute.editNotes)
                    },
                    onClearNotes: {
                        store.setNotes(nil)
                    },
                    onSetDue: {
                        activeSheet = store.makeDraft().map(SingleTaskSheetRoute.editDue)
                    },
                    onClearDue: {
                        store.setDue(nil)
                    },
                    onEdit: {
                        activeSheet = store.makeDraft().map(SingleTaskSheetRoute.editAll)
                    }
                )
                .sheet(item: $activeSheet) { route in
                    switch route {
                    case .editAll(let draft):
                        EditableSingleTaskPlanView(
                            draft: draft,
                            onCancel: { activeSheet = nil },
                            onSave: { newDraft in
                                store.applyDraft(newDraft)
                                activeSheet = nil
                            }
                        )
                    case .editNotes(let draft):
                        QuickTextSheet(
                            initial: draft.notes ?? "",
                            title: "Edit Notes",
                            isMultiline: true,
                            placeholder: "Add notes...",
                            allowEmpty: true,
                            onCancel: {
                            activeSheet = nil
                        }, onSave: { newNotes in
                            var newDraft = draft
                            newDraft.notes = newNotes.trimmed().isEmpty ? nil : newNotes
                            
                            store.applyDraft(newDraft)
                            activeSheet = nil
                        })
                    case .editDue(let draft):
                        QuickDateSheet(
                            initial: draft.dueAt,
                            title: "Due Date",
                            mode: .time,
                            allowClear: true,
                            onCancel: {
                            activeSheet = nil
                        }, onSave: { newDate in
                            var newDraft = draft
                            newDraft.dueAt = newDate
                            store.applyDraft(newDraft)
                            activeSheet = nil
                        }, onClear: {
                            store.setDue(nil)
                            store.applyDraft(draft)
                        })
                    }
                }
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
    SingleTaskHost(plan: .init(title: "Awesome Plan"))
}
