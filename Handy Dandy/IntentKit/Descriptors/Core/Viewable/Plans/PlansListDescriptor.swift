//
//  ReadonlyPlanDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/30/25.
//

import SwiftUI

enum PlanListContext: Equatable {
    case experience(Experience)
    case favorites
    case standalone
    case search(query: String)
    
    var title: String {
        switch self {
        case .experience(let experience): return experience.title
        case .favorites: return "Favorite Plans"
        case .standalone: return "Plans"
        case .search(let query): return "Search: \(query)"
        }
    }
    
    var emptyMessage: String {
        switch self {
        case .experience: return "There are no plans in this experience yet."
        case .favorites: return "No favorite plans yet."
        case .standalone: return "No plans to show."
        case .search: return "No matching plans."
        }
    }
    
    var hasOwner: Bool {
        if case .experience = self {
            return true
        }
        
        return false
    }
}

struct PlansListDescriptor: View {
    let context: PlanListContext
    let plans: [Plan]
    var onOpen: (Plan) -> Void = { _ in }
    var onEdit: (Plan) -> Void = { _ in }
    var onDelete: (Plan) -> Void = { _ in }
    
    var body: some View {
        if plans.isEmpty {
            EmptyPlansListDescriptor(
                message: context.emptyMessage
            )
        } else {
            ForEach(plans) { plan in
                PlanRow(plan: plan)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onOpen(plan)
                    }
                    .contextMenu {
                        Button{ onEdit(plan) } label: { Label("Edit", systemImage: "pencil") }
                        Button(role: .destructive) {
                            onDelete(plan)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }
}

#Preview {
    let experience = Experience(
        title: "Norway Ski Trip",
        type: .flow,
        plans: [
            Plan(title: "First Plan", notes: "First Description", planDate: .now, kind: .checklist, type: .shopping),
            Plan(title: "Second Plan", notes: "Second Description", planDate: .now, kind: .taskList, type: .fitness),
            Plan(title: "Third Plan", notes: "Third Description", planDate: .now, kind: .singleTask, type: .emergency)
        ]
    )
    
    PlansListDescriptor(context: .experience(experience), plans: experience.plans)
}
