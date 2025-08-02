//
//  ShowChecklistsSection.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/24/25.
//

import SwiftUI
import SwiftData

enum PlanFocus : Identifiable {
    case checklist, task
    
    var id: String {
        switch self {
        case .checklist:
            return "checklist"
        case .task:
            return "task"
        }
    }
}

fileprivate enum ChecklistActionType {
    case update(Checklist), delete(Checklist)
}

struct ChecklistsSection: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Bindable var plan: Plan
    @State var showCreateChecklistSheet: Bool = false
    
    var body: some View {
        List {
            Section {
                ForEach($plan.checklists) { $checklist in
                    ChecklistRow(checklist: checklist, mode: .constant(.view))
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        modelContext.delete(plan.checklists[index])
                        plan.checklists.remove(at: index)
                    }
                }
            } header: {
                HStack {
                    Text("Checklists")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                    Button(action: {
                        showCreateChecklistSheet.toggle()
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
        .sheet(isPresented: $showCreateChecklistSheet) {
            ChecklistFormView(checklist: Checklist(plan: plan), mode: .constant(.create))
        }
    }
}

#Preview {
    let plan = Plan(title: "New Plan", description: "New plan description")
    ShowChecklistsSectionPreview(plan: plan)
}

fileprivate struct ShowChecklistsSectionPreview: View {
    @State var plan: Plan
    @State var showCreateChecklistSheet: Bool = false
    
    var body: some View {
        ChecklistsSection(plan: plan, showCreateChecklistSheet: showCreateChecklistSheet)
    }
}
