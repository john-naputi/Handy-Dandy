//
//  ReadonlyChecklistDetailDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/30/25.
//

import SwiftUI

struct ViewableChecklistDetailDescriptor: View {
    var plan: Plan
    var checklist: Checklist
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    let plan = Plan(title: "Test", description: "Plan", planDate: .now)
    let checklist = Checklist(title: "Test", checklistDescription: "Description", plan: plan)
    ViewableChecklistDetailDescriptor(plan: plan, checklist: checklist)
}
