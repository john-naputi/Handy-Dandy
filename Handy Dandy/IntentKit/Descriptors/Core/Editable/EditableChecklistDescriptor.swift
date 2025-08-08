//
//  EditableChecklistDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/29/25.
//

import SwiftUI

struct EditableChecklistDescriptor: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var intent: EditableChecklistIntent
    @State private var draftChecklist: Checklist
    
    init(intent: EditableChecklistIntent) {
        self.intent = intent
        let plan = intent.data.plan
        let checklist = intent.data.checklist
        let setupChecklist = intent.mode == .create
        ? Checklist(title: "", checklistDescription: "", plan: plan)
        : Checklist(title: checklist.title, checklistDescription: checklist.checklistDescription, plan: plan)
        
        _draftChecklist = State(wrappedValue: setupChecklist)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                SectionHeader(title: "Name", isRequired: true) {
                    TextField("Name", text: $draftChecklist.title)
                }
                
                SectionHeader(title: "Description", isRequired: false) {
                    TextField("Description", text: $draftChecklist.checklistDescription)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        let checklist = intent.data.checklist
                        let plan = intent.data.plan
                        
                        commitChanges(to: checklist)
                        if intent.mode == .create {
                            plan.checklists.append(checklist)
                            modelContext.insert(checklist)
                        }
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(draftChecklist.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func commitChanges(to checklist: Checklist) {
        checklist.title = draftChecklist.title
        checklist.checklistDescription = draftChecklist.checklistDescription
    }
}

#Preview {
    let plan = Plan(title: "Test", description: "Description", planDate: .now)
    let checklist = Checklist(title: "Test", checklistDescription: "Description", plan: plan)
    EditableChecklistDescriptorPreview(checklist: checklist, plan: plan)
}

fileprivate struct EditableChecklistDescriptorPreview: View {
    var checklist: Checklist
    var plan: Plan
    
    var body: some View {
        let payload = SingleChecklistPayload(plan: plan, checklist: checklist)
        let intent = EditableChecklistIntent(data: payload, mode: .update)

        EditableChecklistDescriptor(intent: intent)
    }
}
