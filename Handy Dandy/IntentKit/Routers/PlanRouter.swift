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
            SingleTaskContainerHost(plan: plan)
        case .shoppingList:
            Text("Shopping List Coming Soon! - \(plan.title)")
        case .taskList:
            TaskListHost(plan: plan)
        case .checklist:
            TaskListHost(plan: plan)
        }
    }
    
    @ViewBuilder
    static func editContent(for plan: Plan) -> some View {
        switch plan.kind {
        case .singleTask:
            Text("Single Task Editor Coming Soon")
        case .shoppingList:
            Text("Shopping List Editor Coming Soon")
        case .taskList, .checklist:
            TaskListEditHost(plan: plan)
        }
    }
}
