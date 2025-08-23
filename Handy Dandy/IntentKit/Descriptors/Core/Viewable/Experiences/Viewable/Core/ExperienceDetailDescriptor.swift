//
//  ExperienceDetailDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/8/25.
//

import SwiftUI
import SwiftData

struct ExperienceDetailDescriptor: View {
    enum ActiveSheet: Identifiable {
        case addPlan
        case editContent(PlanKind, UUID)
        
        var id: String {
            switch self {
            case .addPlan: return "addPlan"
            case .editContent(let kind, let id): return "editContent-\(kind)-\(id.uuidString)"
            }
        }
    }
    
    @Environment(\.modelContext) private var modelContext
    @State private var showAddPlanSheet = false
    @State private var selectedPlan: Plan?
    @State private var planToDelete: Plan?
    @State private var planToOpen: Plan?
    @State private var activeSheet: ActiveSheet?
    
    @State private var planToEditContent: Plan?
    @State private var selectedPlanToEditMetadata: Plan?
    
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
                            activeSheet = .editContent(plan.kind, plan.planId)
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
                    activeSheet = .addPlan
                } label: {
                    Label("Add Plan", systemImage: "plus.circle.fill")
                }
            }
        }
        .navigationDestination(item: $planToOpen) { plan in
            PlanRouter.view(for: plan)
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .addPlan:
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
                    
                    activeSheet = nil
                }
                
                EditablePlanDescriptorV2(intent: intent)

            case .editContent(let planKind, let planId):
                PlanRouter.editContent(kind: planKind, id: planId)
            }
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
