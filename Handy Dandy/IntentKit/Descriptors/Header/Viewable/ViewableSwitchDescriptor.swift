//
//  ReadonlyDescriptorView.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/29/25.
//

import SwiftUI

struct ViewableSwitchDescriptor: View {
    var caller: ReadonlyDescriptorCaller
    
    var body: some View {
        switch caller {
        case .checklist(let intent):
            ViewableChecklistSwitchDescriptor(intent: intent)
        case .task(let taskIntent):
            ViewableTaskSwitchDescriptor(intent: taskIntent)
        case .plan(let planBindings):
            ViewablePlanDescriptor(bindings: planBindings)
        }
    }
}

#Preview {
    let plan = Plan(title: "Test", description: "Plan", planDate: .now)
    let checklist = Checklist(title: "Checklist", checklistDescription: "Description", plan: plan)
    let payload = SingleChecklistPayload(plan: plan, checklist: checklist)
    let intent = SingleChecklistIntent(data: payload)
    let caller = ReadonlyDescriptorCaller.checklist(intent)
    
    ViewableSwitchDescriptor(caller: caller)
    
}
