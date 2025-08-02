//
//  ReadonlyPlansListDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/30/25.
//

import SwiftUI

struct ViewablePlansListDescriptor: View {
    @Environment(\.modelContext) private var modelContext
    var bindings: MultiPlanIntent
    @State private var showCreatePlanSheet = false
    @State private var showEditPlanSheet: Bool = false
    @State private var selectedPlan: Plan?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(bindings.data) { plan in
                    NavigationLink(destination: SinglePlanDescriptor(plan: plan)) {
                        VStack(alignment: .leading) {
                            Text(plan.title)
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(Color.primary)
                                .accessibilityIdentifier("ViewablePlansList_Title")
                            Text(plan.planDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(Color.primary.opacity(0.7))
                                .accessibilityIdentifier("ViewablePlansList_Date")
                            
                            let description = plan.planDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !description.isEmpty {
                                Text(description)
                                    .font(.body)
                                    .lineLimit(2)
                                    .padding(.top, 4)
                                    .accessibilityIdentifier("ViewablePlansList_Description")
                            }
                        }
                        .onLongPressGesture {
                            selectedPlan = plan
                            showEditPlanSheet.toggle()
                        }
                    }
                }
                .onDelete { indexToRemove in
                    if let targetIndex = indexToRemove.first {
                        modelContext.delete(bindings.data[targetIndex])
                        try? modelContext.save()
                    }
                }
            }
            .navigationTitle("Plans")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreatePlanSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("ViewablePlansList_CreateButton")
                }
            }
            .sheet(isPresented: $showCreatePlanSheet) {
                let plan = Plan(title: "", description: "", planDate: .now)
                let intent = EditablePlanIntent(data: plan, mode: .create)
                let caller = EditableDescriptorCaller.plan(intent)
                EditableDescriptorView(caller: caller)
            }
            .sheet(item: $selectedPlan) { existingPlan in
                let intent = EditablePlanIntent(data: existingPlan, mode: .update)
                let caller = EditableDescriptorCaller.plan(intent)
                EditableDescriptorView(caller: caller)
            }
        }
    }
}

#Preview {
    let plan = [
        Plan(title: "Shopping", description: "Weekly shopping", planDate: .now),
        Plan(title: "Shopping", description: "Weekly shopping", planDate: .now),
        Plan(title: "Shopping", description: "Weekly shopping", planDate: .now)
    ]
    let bindings = MultiPlanIntent(data: plan)
    ViewablePlansListDescriptor(bindings: bindings)
}
