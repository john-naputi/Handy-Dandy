//
//  TaskRow.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/18/25.
//

import SwiftUI

struct TaskRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    let item: GeneralTaskShadow
    var onToggle: () -> Void = {}
    var onDelete: () -> Void = {}
    var onEdit: () -> Void = {}
    
    var body: some View {
        Button(action: onToggle) {
            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 8) {
                        rowIcon
                        rowText
                    }
                } else {
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        rowIcon
                        rowText
                    }
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 6)
        .accessibilityLabel(item.text)
        .accessibilityValue(item.isDone ? "Completed" : "Not Completed")
        .accessibilityHint("Double tap to toggle completion")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: item.isDone ? "Mark as not completed" : "Mark as completed", onToggle)
        .accessibilityAction(named: "Edit", onEdit)
        .accessibilityAction(named: "Delete", onDelete)
        .swipeActions {
            Button(action: onEdit) {
                Label("Edit", systemImage: "square.and.pencil")
            }
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var rowIcon: some View {
        Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
            .imageScale(.large)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(item.isDone ? .green : .primary)
            .accessibilityHidden(true)
    }
    
    private var rowText: some View {
        Text(item.text)
            .strikethrough(item.isDone, pattern: .solid, color: .secondary)
            .foregroundStyle(item.isDone ? .secondary : .primary)
            .lineLimit(nil) // Allows full wrapping at large sizes
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilitySortPriority(1)
    }
}

#Preview {
    let item = GeneralTaskShadow(id: UUID(), text: "Test Item", isDone: true)
    TaskRow(item: item)
}
