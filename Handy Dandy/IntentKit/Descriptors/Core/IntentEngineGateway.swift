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
    case plan(MultiPlanIntent)
    case experience(any ExperienceIntent)
}

enum EditableDescriptorCaller : DescriptorCaller {
    case checklist(EditableChecklistIntent)
    case plan(EditablePlanIntent)
    case task(EditableTaskIntent)
    case experience(EditableExperienceIntent)
    
    func resolveIntent<TIntent>() -> TIntent where TIntent : EditableIntent {
        switch self {
        case .checklist(let intent as TIntent):
            return intent
        default:
            fatalError("Unsupported")
        }
    }
}

struct IntentEngineGateway {
    var header: String
    var mode: InvocationMode
}

struct DescriptorMediator: View {
    var payload: IntentEngineGateway
    
    var body: some View {
        IntentEngineMediator(payload: payload)
    }
}

#Preview {
    let plan = Plan(title: "Plan", description: "Description", planDate: .now)
    let intent = MultiPlanIntent(data: [plan])
    let payload = IntentEngineGateway(header: "Plan", mode: .view(.plan(intent)))
    DescriptorMediator(payload: payload)
}
