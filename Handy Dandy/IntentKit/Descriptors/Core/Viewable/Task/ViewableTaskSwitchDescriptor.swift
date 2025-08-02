//
//  ReadonlyTaskSwtichDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/1/25.
//

import SwiftUI

struct ViewableTaskSwitchDescriptor: View {
    var intent: any TaskIntent
    
    var body: some View {
        switch intent {
        case _ as any PlanTaskIntent:
            Text("Ok")
        case _ as any ChecklistTaskIntent:
            Text("Ok")
        default:
            Text("Invalid intent")
        }
    }
}

#Preview {
    let plan: Plan = Plan(title: "", description: "", planDate: .now)
    let tasks: [ChecklistTask] = [
        ChecklistTask(title: "", description: "", plan: plan)
    ]
    
    let payload = SinglePlanTaskPayload(container: plan, item: tasks[0])
    let intent = SinglePlanTaskIntent(data: payload)
    ViewableTaskSwitchDescriptor(intent: intent)
}
