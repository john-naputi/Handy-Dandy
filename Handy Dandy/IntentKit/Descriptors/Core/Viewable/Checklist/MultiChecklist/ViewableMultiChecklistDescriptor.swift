//
//  ReadonlyMultiChecklistDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/30/25.
//

import SwiftUI

struct ViewableMultiChecklistDescriptor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State var showCreateSheet: Bool = false
    
    var plan: Plan
    
    var body: some View {
        List {
            Section {
                ForEach(plan.checklists) { checklist in
                    let payload = SingleChecklistPayload(plan: plan, checklist: checklist)
                    MultiChecklistRow(payload: payload)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let checklist = plan.checklists[index]
                        plan.checklists.remove(at: index)
                        modelContext.delete(checklist)
                        try? modelContext.save()
                    }
                }
            } header: {
                HStack {
                    Text("Checklists")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                    Button(action: {
                        showCreateSheet.toggle()
                    }) {
                        Label("Add Checklist", systemImage: "plus.circle")
                    }
                    .font(.headline)
                    .buttonStyle(.borderless)
                    .tint(colorScheme == .dark ? .green : .primary)
                    .accessibilityLabel("Add Checklist")
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            let checklist = Checklist(title: "", checklistDescription: "", plan: plan)
            let payload = SingleChecklistPayload(plan: plan, checklist: checklist)
            let intent = EditableChecklistIntent(data: payload, mode: .create)
            
            EditableChecklistDescriptor(intent: intent)
        }
    }
}

#Preview {
    let plan = Plan(
        title: "Shopping",
        description: "For the glory",
        planDate: .now,
        checklist: [
            Checklist(title: "First checklist", checklistDescription: "First description"),
            Checklist(title: "Second checklist", checklistDescription: "Second description"),
            Checklist(title: "Third checklist", checklistDescription: "Third description")
        ]
    )
    
    ReadonlyMultiChecklistDescriptorPreview(plan: plan)
}

fileprivate struct ReadonlyMultiChecklistDescriptorPreview: View {
    @State var showCreateSheet: Bool = false
    var plan: Plan
    
    var body: some View {
        ViewableMultiChecklistDescriptor(showCreateSheet: showCreateSheet, plan: plan)
    }
}
