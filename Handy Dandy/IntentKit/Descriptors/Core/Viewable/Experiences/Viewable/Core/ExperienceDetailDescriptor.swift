//
//  ExperienceDetailDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/8/25.
//

import SwiftUI

struct ExperienceDetailDescriptor: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showAddPlanSheet = false
    
    let experience: Experience
    
    var body: some View {
        NavigationStack {
            let plans = experience.plans
            
            Group {
                if plans.isEmpty {
                    PlansListDescriptor(context: .experience(experience), plans: plans)
                } else {
                    List {
                        Section("Plans") {
                            PlansListDescriptor(
                                context: .experience(experience),
                                plans: plans,
                                onSelect: { plan in
                                    print("Selected \(plan.title)")
                                }
                            )
                        }
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
            .sheet(isPresented: $showAddPlanSheet) {
                let newPlan = Plan()
                let intent = EditablePlanIntent(data: newPlan, mode: .create)
                
                EditablePlanDescriptorV2(intent: intent)
            }
        }
    }
}

#Preview {
    let experience = Experience(
        title: "Norway Ski Trip",
        type: .flow,
        plans: [], tags: [
            ExperienceTag(name: "Norway"),
            ExperienceTag(name: "Skiing")
        ]
    )
    ExperienceDetailDescriptor(experience: experience)
}
