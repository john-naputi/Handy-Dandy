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
    
    @State var mode: ChecklistFormMode = .create
    @State var showCreateTaskSheet: Bool = false
    
    let plan: Plan
    
    var body: some View {
        ChecklistFormView(checklist: Checklist(plan: plan), mode: $mode)
    }
}

#Preview {
    let checklist = Checklist()
    let mode: ChecklistFormMode = .create
    CreateChecklistPreview(checklist: checklist, mode: mode)
}

fileprivate struct CreateChecklistPreview: View {
    @Bindable var checklist: Checklist
    @State var mode: ChecklistFormMode = .create
    
    let plan = Plan(title: "Test Plan", description: "Test Description", planDate: .now)
    
    var body: some View {
        CreateChecklistView(plan: plan)
    }
}
