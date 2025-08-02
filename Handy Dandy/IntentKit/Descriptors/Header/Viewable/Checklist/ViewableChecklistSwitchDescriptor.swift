//
//  ReadonlyChecklistSwtichDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/30/25.
//

import SwiftUI

struct ViewableChecklistSwitchDescriptor: View {
    var intent: ChecklistIntent
    
    var body: some View {
        switch intent {
        case let singleIntent as SingleChecklistIntent:
            ViewableChecklistDetailDescriptor(plan: singleIntent.data.plan, checklist: singleIntent.data.checklist)
        case let multiIntent as MultiChecklistIntent:
            ViewableMultiChecklistDescriptor(plan: multiIntent.data)
        default:
            Text("What have you done!!")
        }
    }
}

#Preview {
    let plan = Plan(title: "Test", description: "Description", planDate: .now)
    let checklist = Checklist(title: "Checklist", checklistDescription: "Checklist Description", plan: plan)
    let payload = SingleChecklistPayload(plan: plan, checklist: checklist)
    let intent = SingleChecklistIntent(data: payload)
    ViewableChecklistSwitchDescriptor(intent: intent)
}
