//
//  CreateChecklistView.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/22/25.
//

import SwiftUI
import Foundation

struct CreateChecklistView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var tasks: [TaskDraft] = []
    
    @FocusState private var focusedTaskID: UUID?
    
    let plan: Plan
    
    var body: some View {
        NavigationStack {
            Form {
                LimitedTextFieldSection(header: "Name", placeholder: "Checklist Name", text: $title)
                LimitedTextEditorInput(sectionHeader: "Description", inputText: $description)
                CreateChecklistTasksSection(tasks: $tasks)
            }
            .navigationTitle("Create Checklist")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let checklist = Checklist(title: title, checklistDescription: description, plan: plan)
                        let tasks: [Task] = tasks.map { draft in
                            Task(title: draft.title, description: draft.description, plan: self.plan, checklist: checklist)
                        }
                        
                        checklist.tasks.append(contentsOf: tasks)
                        plan.checklists.append(checklist)
                        modelContext.insert(checklist)
                        
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let plan = Plan(title: "Test Plan", description: "Test Description", planDate: .now)
    CreateChecklistView(plan: plan)
}
