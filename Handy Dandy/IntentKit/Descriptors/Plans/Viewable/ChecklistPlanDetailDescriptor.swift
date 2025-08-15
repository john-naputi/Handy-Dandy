//
//  ChecklistPlanDetail.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/14/25.
//

import SwiftUI

fileprivate enum ShoppingListRoutes: Hashable {
    case createShopping
    case editShopping(id: UUID)
}

struct ChecklistPlanDetailDescriptor: View {
    @Environment(\.modelContext) private var modelContext
    let plan: Plan
    
    var body: some View {
        List {
            if plan.checklists.isEmpty {
                Section {
                    Text("No checklists yet. Add one to start.")
                }
            }
            
            Section("Checklists") {
                ForEach(plan.checklists) { checklist in
                    switch checklist.kind {
                    case .shoppingList:
                        if let list = checklist.shoppingList {
                            NavigationLink {
                                ShoppingListDetailDescriptor(list: list)
                            } label: {
                                ChecklistRow(checklist: checklist)
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    delete(checklist)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    case .general:
                        Text("General")
                    }
                }
                .onDelete(perform: delete(at:))
                .onMove(perform: move(from:to:))
            }
        }
        .navigationTitle(plan.title.isEmpty ? "Checklists" : plan.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if plan.policy.allowChecklists {
                    Menu {
                        NavigationLink {
                            let shoppingList = ShoppingList()
                            let intent = EditableIntent<ShoppingList, DraftShoppingList>(data: shoppingList, mode: .create, outcome: { outcome in
                                if case .create(let draft) = outcome {
                                    draft.apply(to: shoppingList, for: .create)
                                    let checklist = Checklist(title: draft.name, kind: .shoppingList, shoppingList: shoppingList)
                                    checklist.attach(to: plan)
                                    
                                    modelContext.insert(checklist)
                                    try? modelContext.save()
                                }
                            })
                            
                            EditableShoppingListDescriptor(intent: intent)
                        } label: {
                            Label("Shopping List", systemImage: "cart")
                        }
                    } label: {
                        Label("Add", systemImage: "plus.circle.fill")
                    }
                }
            }
        }
        .animation(.snappy, value: plan.checklists)
    }
    
    // MARK: - ACTIONS
    
    private func delete(_ checklist: Checklist) {
        if let index = plan.checklists.firstIndex(where: { $0.id == checklist.id }) {
            plan.checklists.remove(at: index)
        }
        modelContext.delete(checklist)
        try? modelContext.save()
    }
    
    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let checklist = plan.checklists[index]
            modelContext.delete(checklist)
        }
        
        plan.checklists.remove(atOffsets: offsets)
        try? modelContext.save()
    }
    
    private func move(from src: IndexSet, to dst: Int) {
        plan.checklists.move(fromOffsets: src, toOffset: dst)
        try? modelContext.save()
    }
    
    private func save(_ file: StaticString = #fileID, _ line: UInt = #line) {
        do {
            try modelContext.save()
        } catch {
            #if DEBUG
            print("Save error at \(file):\(line) - \(error)")
            #endif
        }
    }
}

#Preview {
    let plan = Plan(title: "Groceries", kind: .checklist, type: .shopping)
    ChecklistPlanDetailDescriptor(plan: plan)
}
