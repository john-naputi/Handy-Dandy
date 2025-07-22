//
//  PlanDetailView.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/21/25.
//

import SwiftUI

struct PlanDetailView: View {
    @Bindable var plan: Plan
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List {
            Section(header: Text("Checklists")) {
                ForEach(plan.checklists) { checklist in
                    NavigationLink(value: checklist) {
                        VStack(alignment: .leading) {
                            Text(checklist.title)
                                .font(.headline)
                            Text("\(checklist.tasks.filter { $0.isComplete }.count) of \(checklist.tasks.count) complete")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        modelContext.delete(plan.checklists[index])
                    }
                }
                
                Button("Add Checklist") {
                    let checklist = Checklist(title: "New Checklist", plan: plan)
                    plan.checklists.append(checklist)
                }
            }
            
            Section(header: Text("Create Task")) {
                ForEach(plan.tasks.filter { $0.checklist == nil}) { task in
                    HStack {
                        Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                            .onTapGesture {
                                task.isComplete.toggle()
                            }
                    }
                    VStack(alignment: .leading) {
                        Text(task.title)
                        if let description = task.taskDescription {
                            Text(description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let samplePlan = Plan(title: "Weekend Errands")
    
    PlanDetailView(plan: samplePlan)
}
