//
//  ReadonlyMultiTaskListDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/1/25.
//

import SwiftUI

struct ViewableMultiTaskListDescriptor: View {
    var intent: MultiPlanTaskIntent
    
    var body: some View {
        // TODO: Implement this delegate!!!
        let delegate = ViewableTaskActionDelegate()
        ViewableTaskListDescriptor(container: intent.data.container, delegate: delegate)
    }
}

#Preview {
    let plan = Plan(title: "Test", description: "Plan Description", planDate: .now, tasks: [
        Task(title: "First Task", description: "First Task Description"),
        Task(title: "Second Task", description: "Second Task Description"),
        Task(title: "Third Task", description: "Third Task Description")
    ])
    let payload = MultiPlanTaskPayload(container: plan, item: plan.tasks)
    let intent = MultiPlanTaskIntent(data: payload)
    ViewableMultiTaskListDescriptor(intent: intent)
}
