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
    @State private var showAddPlanSheet: Bool = false
    let plans: [Plan]
    
    var body: some View {
        NavigationStack {
            if plans.isEmpty {
                EmptyPlansListDescriptor(
                    title: "Plans",
                    message: "There are no plans for this experience."
                )
            } else {
                List(plans) { plan in
                    PlanRow(plan: plan)
                }
                .navigationTitle("Plans")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showAddPlanSheet.toggle()
                        } label: {
                            Label("Plan", systemImage: "plus.circle.fill")
                        }
                    }
                }
                .sheet(isPresented: $showAddPlanSheet) {
                    let plan = Plan()
                    let intent = EditablePlanIntent(data: plan, mode: .create)
                    
                    EditablePlanDescriptorV2(intent: intent)
                }
            }
        }
    }
}

#Preview {
    let plans: [Plan] = [
        Plan(title: "First Plan", description: "First Description", planDate: .now, kind: .checklist, type: .shopping),
        Plan(title: "Second Plan", description: "Second Description", planDate: .now, kind: .taskList, type: .workout),
        Plan(title: "Third Plan", description: "Third Description", planDate: .now, kind: .singleTask, type: .emergency)
    ]
    
    PlansListDescriptor(plans: plans)
}
