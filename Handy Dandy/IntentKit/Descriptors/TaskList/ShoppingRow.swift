//
//  ShoppingRow.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/20/25.
//

import SwiftUI

struct ShoppingRow: View {
    let item: ShoppingItemShadow
    var onToggle: () -> Void
    var onDelete: () -> Void
    var onEdit: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                .imageScale(.large)
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)

            Text(item.name)
                .strikethrough(item.isDone, pattern: .solid, color: .secondary)
                .foregroundStyle(item.isDone ? .secondary : .primary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onToggle)
        .swipeActions {
            Button(action: onEdit) {
                Label("Edit", systemImage: "square.and.pencil")
            }
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
        .contextMenu {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
        // A11y
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.name)
        .accessibilityValue(item.isDone ? "Completed" : "Not completed")
        .accessibilityHint("Double-tap to toggle completion. Swipe up or down for actions.")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: item.isDone ? "Mark as not completed" : "Mark as completed", onToggle)
        .accessibilityAction(named: "Edit", onEdit)
        .accessibilityAction(named: "Delete", onDelete)
    }
}

#Preview {
    ShoppingRow(item: ShoppingItemShadow(), onToggle: {}, onDelete: {}, onEdit: {})
}
