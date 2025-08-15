//
//  ChecklistPlanDetail.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/14/25.
//

import SwiftUI

fileprivate enum SheetRoute: Identifiable {
    case createShopping
    case editShopping(list: ShoppingList)
    
    var id: String {
        switch self {
        case .createShopping: return "create-shopping"
        case .editShopping(let list): return "edit-\(list.id.uuidString)"
        }
    }
}

struct ChecklistPlanDetailDescriptor: View {
    @Environment(\.modelContext) private var modelContext
    @State private var route: SheetRoute? = nil
    
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
                    Button {
                        switch checklist.kind {
                        case .shoppingList:
                            if let list = checklist.shoppingList {
                                route = .editShopping(list: list)
                            }
                        case .general:
                            // TODO: present general checklist editor
                            break
                        }
                    } label: {
                        ChecklistRow(checklist: checklist)
                    }
                    .contextMenu {
                        if checklist.kind == .shoppingList {
                            Button {
                                if let list = checklist.shoppingList {
                                    route = .editShopping(list: list)
                                }
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                        
                        Button(role: .destructive) {
                            delete(checklist)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
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
                        Button {
                            route = .createShopping
                        } label: {
                            Label("Shopping List", systemImage: "cart")
                        }
                    } label: {
                        Label("Add", systemImage: "plus.circle.fill")
                    }
                }
            }
        }
        .sheet(item: $route, onDismiss: { route = nil }) { selectedRoute in
            switch selectedRoute {
            case .createShopping:
                let shoppingList = ShoppingList()
                let intent = EditableIntent<ShoppingList, DraftShoppingList>(data: shoppingList, mode: .create, outcome: { outcome in
                    switch outcome {
                    case .create(let draft):
                        draft.apply(to: shoppingList, for: .create)
                        let checklist = Checklist(title: draft.name, kind: ChecklistKind.shoppingList, shoppingList: shoppingList)
                        checklist.attach(to: plan)
                        modelContext.insert(checklist)
                        
                        try? modelContext.save()
                    default:
                        assertionFailure("Invalid action for create-only intent.")
                    }
                })
                
                EditableShoppingListDescriptor(intent: intent)
            
            case .editShopping(let list):
                let intent = EditableIntent<ShoppingList, DraftShoppingList>(data: list, mode: .edit, outcome: { outcome in
                    switch outcome {
                    case .update(let draft):
                        draft.apply(to: list, for: .edit)
                        try? modelContext.save()
                    default:
                        assertionFailure("Invalid action for edit-only intent.")
                    }
                })
                
                EditableShoppingListDescriptor(intent: intent)
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
