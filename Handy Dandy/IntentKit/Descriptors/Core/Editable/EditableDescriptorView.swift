//
//  EditableDescriptorView.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/29/25.
//

import SwiftUI

enum DescriptorFieldFocus : Hashable {
    case title, description, date
}

struct EditableDescriptorView: View {
    var caller: EditableDescriptorCaller
    
    var body: some View {
        switch caller {
        case .checklist(let intent):
            EditableChecklistDescriptor(intent: intent)
        case .task(let taskIntent):
            EditableTaskDescriptor(intent: taskIntent)
        case .plan(let planBindings):
            EditablePlanSwitchDescriptor(bindings: planBindings)
        case .experience(let experienceIntent):
            EditableExperienceDescriptor(intent: experienceIntent)
        }
    }
}

#Preview {
    let plan = Plan(title: "Plan", description: "Description")
    let checklist = Checklist(title: "Checklist", checklistDescription: "Description", plan: plan)
    let intent = EditableChecklistIntent(data: SingleChecklistPayload(plan: plan, checklist: checklist), mode: .update)
    let caller = EditableDescriptorCaller.checklist(intent)
    EditableDescriptorView(caller: caller)
}
