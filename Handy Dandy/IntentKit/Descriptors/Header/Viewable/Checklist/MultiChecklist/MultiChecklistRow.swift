//
//  MultiChecklistRow.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/30/25.
//

import SwiftUI

struct MultiChecklistRow: View {
    var payload: SingleChecklistPayload
    
    var body: some View {
        let checklist = payload.checklist
        NavigationLink(destination: ViewableChecklistDescriptor(payload: payload)) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(checklist.title)
                        .font(.headline)
                    Text("\(checklist.tasks.filter { $0.isComplete }.count) of \(checklist.tasks.count) complete")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if checklist.isComplete {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.green)
                            .imageScale(.small)
                            .accessibilityLabel("Checklist complete")
                    }
                }
                
                let description = checklist.checklistDescription
                if !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(description)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}

#Preview {
    let plan = Plan(title: "Test", description: "Plan", planDate: .now)
    let checklist = Checklist(title: "Costco", checklistDescription: "Monthly shopping", plan: plan)
    
    let payload = SingleChecklistPayload(plan: plan, checklist: checklist)
    
    MultiChecklistRow(payload: payload)
}
