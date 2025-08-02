//
//  CheckListFormSection.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/23/25.
//

import SwiftUI

struct CheckListFormSection: View {
    @Bindable var checklist: Checklist
    @State var mode: ChecklistFormMode
    
    var onAddTaskTapped: () -> Void
    
    var body: some View {
        Section(header: Text("Checklist Details")) {
            LimitedTextFieldSection(header: "Checklist Title", placeholder: "", text: $checklist.title)
            LimitedTextEditorInput(sectionHeader: "Description", inputText: $checklist.checklistDescription)
            ChecklistTaskSection(checklist: checklist, mode: $mode, onAddTaskTapped: onAddTaskTapped)
//            ChecklistTaskSection(state: state, onAddTaskTapped: onAddTaskTapped)
        }
    }
}

//#Preview {
//    CheckListFormSection(title: Bindable(wrappedValue: ""), description: Bindable(wrappedValue: ""), tasks: Bindable(wrappedValue: []))
//}
