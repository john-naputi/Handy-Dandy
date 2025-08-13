//
//  EditableChecklistSwitchDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/12/25.
//

import SwiftUI

struct EditableChecklistSwitchDescriptor: View {
    var intent: any EditableChecklistIntent
    
    var body: some View {
        switch intent {
        case let intent as EditableGeneralChecklistIntent:
            EditableChecklistDescriptor(intent: intent)
        case let intent as EditableShoppingListIntent:
            Text("Not Implemented")
        default:
            Text("This is an invalid intent")
        }
    }
}

#Preview {
    let plan = Plan(title: "Test", checklists: [Checklist(title: "First Checklist")])
    let payload = SingleChecklistPayload(plan: plan, checklist: plan.checklists[0])
    let intent = EditableGeneralChecklistIntent(data: payload, mode: .create)
    EditableChecklistSwitchDescriptor(intent: intent)
}
