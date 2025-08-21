//
//  ExperienceDetailDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/8/25.
//

import SwiftUI
import SwiftData

struct ExperienceDetailDescriptor: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showAddPlanSheet = false
    @State private var selectedPlan: Plan?
    @State private var planToDelete: Plan?
    @State private var planToOpen: Plan?
    
    let experience: Experience
    
    var body: some View {
        let plans = experience.plans
        
        Group {
            if plans.isEmpty {
                PlansListDescriptor(context: .experience(experience), plans: plans)
            } else {
                List {
                    PlansListDescriptor(
                        context: .experience(experience),
                        plans: plans,
                        onOpen: { plan in
                            planToOpen = plan
                        },
                        onEdit: { plan in
                            selectedPlan = plan
                        },
                        onDelete: { plan in
                            planToDelete = plan
                        }
                    )
                }
            }
        }
        .navigationTitle("Plans")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddPlanSheet.toggle()
                } label: {
                    Label("Add Plan", systemImage: "plus.circle.fill")
                }
            }
        }
        .navigationDestination(item: $planToOpen) { plan in
            PlanRouter.view(for: plan)
        }
        .sheet(isPresented: $showAddPlanSheet) {
            let newPlan = Plan()
            let intent = EditableIntent<Plan, DraftPlan>(data: newPlan, mode: .create) { outcome in
                switch outcome {
                case .create(let draft):
                    draft.move(to: newPlan)
                    experience.add(plan: newPlan)
                    modelContext.insert(newPlan)
                    try? modelContext.save()
                case .cancel:
                    showAddPlanSheet = false
                default:
                    assertionFailure("Invalid outcome for a create-only action.")
                }
            }
            
            EditablePlanDescriptorV2(intent: intent)
        }
        .sheet(item: $selectedPlan) { plan in
            let intent = EditableIntent<Plan, DraftPlan>(data: plan, mode: .edit) { outcome in
                switch outcome {
                case .update(let draft):
                    guard let index = experience.plans.firstIndex(where: { $0.id == plan.id }) else {
                        assertionFailure("The plan you are trying to update does not exist")
                        return
                    }
                    
                    draft.move(to: plan)
                    self.experience.plans[index].title = plan.title
                    self.experience.plans[index].notes = plan.notes
                    self.experience.plans[index].kind = plan.kind
                    self.experience.plans[index].type = plan.type
                    
                    if let list = try? TaskListBridge(context: self.modelContext).fetchOrCreate(for: plan), list.title != plan.title {
                        list.title = plan.title
                        try? self.modelContext.save()
                    }
                case .cancel:
                    selectedPlan = nil
                default:
                    assertionFailure("Invalid outcome for an update-only action for experiences.")
                }
            }
            
            EditablePlanDescriptorV2(intent: intent)
        }
        .alert(
            "Delete Plan?",
            isPresented: .init(
                get: { self.planToDelete != nil },
                set: { if !$0 { self.planToDelete = nil }}
            ),
            presenting: self.planToDelete,
            actions: { targetPlan in
                Button("Delete", role: .destructive) {
                    guard let index = self.experience.plans.firstIndex(where: { $0.id == targetPlan.id }) else {
                        return
                    }
                    
                    self.experience.plans.remove(at: index)
                    modelContext.delete(targetPlan)
                    
                    try? modelContext.save()
                }
                
                Button("Cancel", role: .cancel) {
                    planToDelete = nil
                }
            },
            message: { targetPlan in
                Text("Are you sure you want to delete the plan: \(targetPlan.title)?")
            }
        )
    }
}

#Preview {
    let experience = Experience(
        title: "Norway Ski Trip",
        type: .flow,
        plans: [
            Plan(title: "Grocery Run", kind: .checklist, type: PlanType.shopping),
            Plan(title: "Post-Work Excercise", kind: .singleTask, type: PlanType.fitness),
            Plan(title: "Check In Hubby", kind: .singleTask, type: PlanType.emergency),
        ],
        tags: [
            ExperienceTag(name: "Norway"),
            ExperienceTag(name: "Skiing")
        ]
    )
    ExperienceDetailDescriptor(experience: experience)
}
