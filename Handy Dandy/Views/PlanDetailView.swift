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
    
    @State private var showCreateTaskSheet = false
    
    var body: some View {
        List {
            Section(header: Text("Checklists")) {
                ForEach(plan.checklists) { checklist in
                    NavigationLink(value: checklist) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(checklist.title)
                                    .font(.headline)
                                Text("\(checklist.tasks.filter { $0.isComplete }.count) of \(checklist.tasks.count) complete")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            if let description = checklist.checklistDescription, !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text(description)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        modelContext.delete(plan.checklists[index])
                    }
                }
                
                Button("Add Checklist") {
                    showCreateTaskSheet.toggle()
                }
            }
            
            Section {
                ForEach(plan.tasks.filter { $0.checklist == nil}) { task in
                    HStack {
                        Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                            .onTapGesture {
                                task.isComplete.toggle()
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
            } header: {
                HStack {
                    Text("Tasks")
                    Spacer()
                    Button(action: {
                        showCreateTaskSheet.toggle()
                    }) {
                        Label("Add Task", systemImage: "plus.circle")
                            .foregroundStyle(Color(.blue))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Add Task")
                }
            }
        }
        .sheet(isPresented: $showCreateTaskSheet) {
            CreateTaskSheet { newTask in
                let task = Task(title: newTask.title, description: newTask.description, plan: plan, checklist: nil)
                modelContext.insert(task)
                plan.tasks.append(task)
            }
        }
    }
}

#Preview {
    let samplePlan = Plan(title: "Weekend Errands")
    
    PlanDetailView(plan: samplePlan)
}
