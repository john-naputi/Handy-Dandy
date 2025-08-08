//
//  EditablePlanSwitchDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/30/25.
//

import SwiftUI

struct EditablePlanSwitchDescriptor: View {
    var bindings: PlanIntent
    
    var body: some View {
        switch bindings {
        case let singleIntent as EditablePlanIntent:
            EditablePlanDescriptor(intent: singleIntent)
        case _ as MultiPlanIntent:
            VStack(alignment: .center) {
                Text("There was a problem when trying to edit the plan!!!")
            }
        default:
            VStack(alignment: .center) {
                Text("There was a problem when trying to edit the plan!!!")
            }
        }
    }
}

#Preview {
    let plan = Plan(title: "Plan", description: "Description", planDate: .now)
    let binding = SinglePlanIntent(data: plan)
    EditablePlanSwitchDescriptorPreview(bindings: binding)
}

fileprivate struct EditablePlanSwitchDescriptorPreview: View {
    var bindings: PlanIntent
    @FocusState var focusedField: DescriptorFieldFocus?
    
    var body: some View {
        EditablePlanSwitchDescriptor(bindings: bindings)
    }
}
