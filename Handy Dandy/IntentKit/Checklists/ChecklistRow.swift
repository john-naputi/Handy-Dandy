//
//  ChecklistRow.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/27/25.
//

import SwiftUI

struct ChecklistRow: View {
    @Bindable var checklist: Checklist
    @Binding var mode: ChecklistFormMode
    
    var body: some View {
        NavigationLink(
            destination: ChecklistDetailsView(checklist: checklist, mode: .view),
            label: {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(checklist.title)
                            .font(.headline)
                        Text("\(checklist.tasks.filter { $0.isComplete }.count) of \(checklist.tasks.count) complete")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if checklist.isComplete {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.green)
                                .imageScale(.small)
                                .accessibilityLabel("Checklist complete")
                        }
                    }
                    
                    let description = checklist.checklistDescription
                    if !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(description)
                            .font(.body)
                            .foregroundStyle(.primary)
                    }
                }
            }
        )
    }
}

#Preview {
    let checklist = Checklist(title: "Awesome Checklist", checklistDescription: "Something awesome", tasks: [], plan: nil)
    let mode = ChecklistFormMode.view
    ChecklistRowPreview(checklist: checklist, mode: mode)
}

fileprivate struct ChecklistRowPreview: View {
    @State var checklist: Checklist
    @State var mode: ChecklistFormMode
    
    var body: some View {
        ChecklistRow(checklist: checklist, mode: $mode)
    }
}
