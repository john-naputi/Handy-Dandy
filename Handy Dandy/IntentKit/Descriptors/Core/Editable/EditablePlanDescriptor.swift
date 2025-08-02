//
//  EditableTaskDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/29/25.
//

import SwiftUI

struct EditablePlanDescriptor: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var intent: EditablePlanIntent
    @State var draftPlan: Plan
    
    init(intent: EditablePlanIntent) {
        self.intent = intent
        let plan = intent.data
        let setupPlan = intent.mode == .create
        ? Plan(title: "", description: "", planDate: .now)
        : Plan(title: plan.title, description: plan.planDescription, planDate: plan.planDate)
        
        _draftPlan = State(wrappedValue: setupPlan)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                SectionHeader(title: "Name", isRequired: true) {
                    TextField("Name", text: $draftPlan.title)
                        .accessibilityIdentifier("EditablePlan_NameTextField")
                }
                
                SectionHeader(title: "Description", isRequired: false) {
                    TextField("Description", text: $draftPlan.planDescription)
                        .accessibilityIdentifier("EditablePlan_DescriptionTextField")
                }
                
                SectionHeader(title: "Plan Date", isRequired: true) {
                    DatePicker("Select a date", selection: $draftPlan.planDate, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .accessibilityIdentifier("EditablePlan_DatePicker")
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityIdentifier("PlanCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        let plan = intent.data
                        commitChanges(to: plan)
                        
                        if intent.mode == .create {
                            modelContext.insert(plan)
                        }
                        
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(draftPlan.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("EditablePlan_ConfirmButton")
                }
            }
        }
    }
    
    private func commitChanges(to plan: Plan) {
        plan.title = draftPlan.title
        plan.planDescription = draftPlan.planDescription
        plan.planDate = draftPlan.planDate
    }
}

#Preview {
    let plan = Plan(title: "Test Plan")
    let intent = EditablePlanIntent(data: plan, mode: .update)
    EditablePlanDescriptorPreview(intent: intent)
}

fileprivate struct EditablePlanDescriptorPreview: View {
    var intent: EditablePlanIntent
    
    var body: some View {
        EditablePlanDescriptor(intent: intent)
    }
}
