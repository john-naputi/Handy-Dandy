//
//  ReadonlyPlanTaskListDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/1/25.
//

import SwiftUI

struct ViewablePlanTaskDetailDescriptor: View {
    var intent: SinglePlanTaskIntent
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

//#Preview {
//    let plan: Plan = Plan(title: "Test", description: "Test", planDate: .now)
//    let tasks: [Task] = [
//        Task(title: "First Task", description: "The First Task", isComplete: false, plan: plan, checklist: nil)
//    ]
//    plan.tasks = tasks
//    
//    let payload: SinglePlanTaskPayload = SinglePlanTaskPayload(container: plan, item: tasks[0])
//    let intent: SinglePlanTaskIntent = SinglePlanTaskIntent(data: payload)
//    ReadonlyPlanTaskDetailDescriptor(intent: intent)
//}
