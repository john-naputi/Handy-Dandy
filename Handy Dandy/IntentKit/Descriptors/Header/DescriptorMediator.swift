//
//  HeaderDescriptorView.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/29/25.
//

import SwiftUI

protocol DescriptorCaller {}

enum InvocationMode {
    case view(ReadonlyDescriptorCaller)
    case edit(EditableDescriptorCaller)
}

enum AnyDescriptorCaller {
    case read(ReadonlyDescriptorCaller)
    case edit(EditableDescriptorCaller)
}

enum ReadonlyDescriptorCaller : DescriptorCaller {
    case checklist(ChecklistIntent)
    case task(any TaskIntent)
    case plan(PlanIntent)
}

enum EditableDescriptorCaller : DescriptorCaller {
    case checklist(EditableChecklistIntent)
    case plan(EditablePlanIntent)
    case task(EditableTaskIntent)
    
    func resolveIntent<TIntent>() -> TIntent where TIntent : EditableIntent {
        switch self {
        case .checklist(let intent as TIntent):
            return intent
        default:
            fatalError("Unsupported")
        }
    }
}

struct DescriptorPayload {
    var header: String
    var mode: InvocationMode
}

struct DescriptorMediator: View {
    var payload: DescriptorPayload
    
    var body: some View {
        DescriptorView(payload: payload)
    }
}

#Preview {
    let plan = Plan(title: "Plan", description: "Description", planDate: .now)
    let bindings = SinglePlanIntent(data: plan)
    let payload = DescriptorPayload(header: "Plan", mode: .view(.plan(bindings)))
    DescriptorMediator(payload: payload)
}
