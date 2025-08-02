//
//  ReadonlyPlanTaskSwitchDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/1/25.
//

import SwiftUI

struct ViewablePlanTaskSwitchDescriptor: View {
    var intent: any PlanTaskIntent
    
    var body: some View {
        switch intent {
        case let singleTaskIntent as SinglePlanTaskIntent:
            ViewablePlanTaskDetailDescriptor(intent: singleTaskIntent)
        case let multiTaskIntent as MultiPlanTaskIntent:
            Text("Ok")
        default:
            Text("Invalid plan task type")
        }
    }
}

#Preview {
    let plan = Plan(title: "Test Plan", description: "Description", planDate: .now)
    let payload = MultiPlanTaskPayload(container: plan, item: plan.tasks)
    let intent = MultiPlanTaskIntent(data: payload)
    ViewablePlanTaskSwitchDescriptor(intent: intent)
}
