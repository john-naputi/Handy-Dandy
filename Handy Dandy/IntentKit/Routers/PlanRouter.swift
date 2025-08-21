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
            Text("Single Task Coming Soon! - \(plan.title)")
        case .shoppingList:
            Text("Shopping List Coming Soon! - \(plan.title)")
        case .taskList:
            TaskListHost(plan: plan)
        case .checklist:
            TaskListHost(plan: plan)
        }
    }
}
