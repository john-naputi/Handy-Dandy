//
//  TaskItemsSection.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/20/25.
//

import SwiftUI

struct TaskItemsSection<Row: View>: View {
    let header: Text?
    let items: [TaskListItemShadow]
    let onToggle: (UUID) -> Void
    let onDelete: (UUID) -> Void
    let onEdit: (TaskListItemShadow) -> Void
    let isCompletedSection: Bool
    let rowContent: (TaskListItemShadow) -> Row
    
    var body: some View {
        Section {
            ForEach(items) { item in
                rowContent(item)
                    .swipeActions {
                        if isCompletedSection {
                            Button { onToggle(item.id) } label: { Label("Undo", systemImage: "arrow.uturn.left") }
                        } else {
                            Button { onToggle(item.id) } label: { Label("Done", systemImage: "checkmark") }
                        }
                        Button(role: .destructive) { onDelete(item.id) } label: { Label("Delete", systemImage: "trash") }
                    }
                    .contextMenu {
                        Button { onEdit(item) } label: { Label("Edit", systemImage: "pencil") }
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
            }
        } header: {
            if let header { header.textCase(nil) }
        }
    }
}

#Preview {
    TaskItemsSection(header: Text("The Header"), items: [], onToggle: { _ in }, onDelete: { _ in }, onEdit: { _ in }, isCompletedSection: false) { item in
        Text(item.title)
    }
}
