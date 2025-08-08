//
//  PlanDetailDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/8/25.
//

import SwiftUI

struct PlanDetailDescriptor: View {
    let plan: Plan
    
    var body: some View {
        switch plan.kind {
        case .singleTask:
            Text("Single Task")
        case .taskList:
            Text("Task List")
        case .checklist:
            Text("Checklist")
        }
    }
}

#Preview {
    let plan = Plan(title: "Oil Change", kind: .singleTask)
    PlanDetailDescriptor(plan: plan)
}
