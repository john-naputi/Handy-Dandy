//
//  ReadonlyPlanDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/30/25.
//

import SwiftUI

struct MultiPlanDescriptor: View {
    var intent: MultiPlanIntent
    
    var body: some View {
        List(intent.data) { plan in
            PlanRow(plan: plan)
        }
    }
}

#Preview {
    let plans: [Plan] = [
        Plan(title: "First Plan", description: "First Description", planDate: .now, kind: .checklist, type: .shopping),
        Plan(title: "Second Plan", description: "Second Description", planDate: .now, kind: .taskList, type: .workout),
        Plan(title: "Third Plan", description: "Third Description", planDate: .now, kind: .singleTask, type: .emergency)
    ]
    let intent = MultiPlanIntent(data: plans)
    
    MultiPlanDescriptor(intent: intent)
}
