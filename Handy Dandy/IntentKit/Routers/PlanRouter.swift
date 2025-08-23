//
//  PlanRouter.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/20/25.
//

import SwiftUI

struct PlanRouter {
    @ViewBuilder
    static func view(for plan: Plan) -> some View {
        switch plan.kind {
        case .singleTask:
            SingleTaskHost(plan: plan)
        case .shoppingList:
            Text("Shopping List Coming Soon! - \(plan.title)")
        case .taskList:
            TaskListHost(plan: plan)
        case .checklist:
            TaskListHost(plan: plan)
        }
    }
    
    @ViewBuilder
    static func editContent(kind: PlanKind, id: UUID) -> some View {
        switch kind {
        case .singleTask:
            SingleTaskEditHost(planId: id)
        case .shoppingList:
            Text("Shopping List Editor Coming Soon")
        case .taskList, .checklist:
            TaskListEditHost(planId: id)
        }
    }
}
