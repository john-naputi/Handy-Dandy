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

struct ChecklistPlanDetail: View {
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
                        
                    }
                }
            }
        }
    }
}

#Preview {
    let plan = Plan(title: "Groceries", kind: .checklist, type: .shopping)
    ChecklistPlanDetail(plan: plan)
}
