//
//  ChecklistDetailsView.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/24/25.
//

import SwiftUI

struct ChecklistDetailsView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var checklist: Checklist
    @State var mode: ChecklistFormMode
    
    var body: some View {
        ChecklistFormView(
            checklist: checklist,
            mode: $mode,
            onEditPressed: {
                mode = .edit
            }
        )
    }
}

#Preview {
    ChecklistDetailsViewPreview()
}

private struct ChecklistDetailsViewPreview: View {
    @Bindable var checklist: Checklist = Checklist(title: "Sample", checklistDescription: "Sample", plan: nil)
    
    var body: some View {
        ChecklistDetailsView(checklist: checklist, mode: .view)
    }
}
