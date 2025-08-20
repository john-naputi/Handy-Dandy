//
//  PlanRow.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/8/25.
//

import SwiftUI

struct PlanRow: View {
    let plan: Plan
    
    private var summaryLine: String {
        switch plan.kind {
        case .singleTask:
            return "Single Task • \(plan.type.displayName)"
        case .taskList:
            let completed = plan.tasks.filter { $0.isComplete }.count
            let total = plan.tasks.count
            
            return "Task List • \(completed) of \(total) completed"
        case .checklist:
            let checklistCount = plan.checklists.count
            
            if checklistCount == 0 {
                return "Checklist • No Checklists"
            } else {
                return "Checklist • \(checklistCount) \(checklistCount == 1 ? "list" : "lists")"
            }
            // TODO: FIX THIS SHOPPING LIST ITEM
        case .shoppingList:
            return "Shopping List • \(plan.tasks.count) items"
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: plan.type.symbol)
                .font(.system(size: 24))
                .foregroundStyle(plan.type.tintColor)
            VStack(alignment: .leading, spacing: 4) {
                Text(plan.title)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(summaryLine)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                if let notes = plan.notes, !notes.isEmpty {
                    Text(plan.description())
                        .font(.body)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let plan = Plan(title: "Grocery Shopping", kind: .checklist, type: .fitness)
    PlanRow(plan: plan)
}
