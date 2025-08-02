//
//  ReadonlyPlanDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/30/25.
//

import SwiftUI

struct ViewablePlanDescriptor: View {
    var bindings: PlanIntent
    
    var body: some View {
        switch bindings {
        case let singleBindings as SinglePlanIntent:
            ViewablePlanDescriptor(bindings: singleBindings)
        case let collectionBindings as MultiPlanIntent:
            ViewablePlansListDescriptor(bindings: collectionBindings)
        default:
            Text("Invalid bindings!!!")
        }
    }
}

#Preview {
    let plans: [Plan] = [
        Plan(title: "First Plan", description: "First Description", planDate: .now),
        Plan(title: "Second Plan", description: "Second Description", planDate: .now),
        Plan(title: "Third Plan", description: "Third Description", planDate: .now)
    ]
    let collectionBindings = MultiPlanIntent(data: plans)
    
    ViewablePlanDescriptor(bindings: collectionBindings)
}
