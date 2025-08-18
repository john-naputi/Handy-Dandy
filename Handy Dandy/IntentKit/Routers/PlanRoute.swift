//
//  PlanRoute.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/19/25.
//

import Foundation

enum PlanRoute: Hashable, Identifiable {
    case taskList(planId: UUID)
    case singleTask(planId: UUID)
    case shoppingList(planId: UUID)
    
    var id: String {
        switch self {
        case .taskList(planId: let planId): return "taskList: \(planId.uuidString)"
        case .singleTask(planId: let planId): return "singleTask: \(planId.uuidString)"
        case .shoppingList(planId: let planId): return "shoppingList: \(planId.uuidString)"
        }
    }
    
    static func from(_ plan: Plan) -> PlanRoute {
        switch (plan.kind, plan.type) {
        case (.taskList, _): return .taskList(planId: plan.planId)
        case (.singleTask, _): return .singleTask(planId: plan.planId)
        case (.shoppingList, _): return .shoppingList(planId: plan.planId)
        case (.checklist, _): return .shoppingList(planId: plan.planId)
        }
    }
}
