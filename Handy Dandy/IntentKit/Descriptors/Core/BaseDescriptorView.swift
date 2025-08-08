//
//  DescriptorView.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/29/25.
//

import SwiftUI

struct BaseDescriptorView: View {
    var payload: DescriptorPayload
    
    var body: some View {
        VStack(alignment: .leading) {
            switch payload.mode {
            case .view(let viewCaller):
                ViewableSwitchDescriptor(caller: viewCaller)
            case .edit(let editableCaller):
                EditableDescriptorView(caller: editableCaller)
            }
        }
    }
}

#Preview {
    let plan = Plan(title: "Plan", description: "Plan Description", planDate: .now)
    let intent = SinglePlanIntent(data: plan)
    let payload = DescriptorPayload(
        header: "Plans",
        mode: .view(.plan(intent))
    )
    
    BaseDescriptorView(payload: payload)
}
