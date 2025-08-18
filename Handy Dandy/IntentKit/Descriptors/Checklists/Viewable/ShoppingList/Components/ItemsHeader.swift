//
//  ItemsHeader.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/17/25.
//

import SwiftUI

struct ItemsHeader: View {
    @Environment(\.dynamicTypeSize) private var dts

    @Binding var isEditingItems: Bool
    @Binding var currentSort: SortKind

    var addItem: () -> Void
    var sortByName: () -> Void
    var sortByPrice: () -> Void
    var markAllDone: () -> Void

    // Your rule: a11y sizes => collapse to a single menu
    private var collapseToMenu: Bool { dts.isAccessibilitySize }

    var body: some View {
        if collapseToMenu {
            // Accessibility sizes: title + one Actions menu
            VStack(alignment: .leading, spacing: 8) {
                title
                actionsMenu(label: "Actions", icon: "ellipsis.circle")
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
                    .accessibilityLabel("Actions")
                    .accessibilityHint("Add item, edit items, sort, or mark all done")
            }
            .accessibilityElement(children: .contain)
        } else {
            // Normal sizes: icon-only controls, keep it speedy
            ViewThatFits(in: .horizontal) {
                // Single row if it fits
                HStack(spacing: 12) {
                    title
                    Spacer(minLength: 8)
                    controlsIconOnlyRow
                }
                // Two rows if it doesn’t
                VStack(alignment: .leading, spacing: 8) {
                    title
                    controlsIconOnlyRow
                }
            }
            .accessibilityElement(children: .contain)
        }
    }

    // MARK: - Subviews

    private var title: some View {
        Text("Items")
            .font(.headline)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel("Items")
            .accessibilityValue("Header for items section")
    }

    // Fast, icon-only controls (normal sizes)
    private var controlsIconOnlyRow: some View {
        HStack(spacing: 10) {
            Button {
                isEditingItems.toggle()
            } label: {
                Label("Edit Items", systemImage: isEditingItems ? "checkmark.circle" : "pencil.circle")
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .frame(minHeight: 44) // tap target
            .accessibilityLabel(isEditingItems ? "Finish editing items" : "Edit items")
            .accessibilityHint(isEditingItems ? "Exit item edit mode" : "Enter item edit mode")

            Button(action: addItem) {
                Label("Add Item", systemImage: "plus.circle")
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .frame(minHeight: 44)
            .accessibilityLabel("Add item")

            actionsMenu(label: "Sort / More", icon: "arrow.up.arrow.down.circle")
                .labelStyle(.iconOnly)
                .buttonStyle(.bordered)
                .controlSize(.regular)
                .frame(minHeight: 44)
                .accessibilityLabel("More actions")
                .accessibilityHint("Sort items or mark all done")
        }
    }

    // Shared Actions menu content
    @ViewBuilder
    private func actionsMenu(label: String, icon: String) -> some View {
        Menu {
            // If we’re collapsed (a11y), include Edit/ Add inside menu too
            if collapseToMenu {
                Button {
                    addItem()
                } label: {
                    Label("Add Item", systemImage: "plus.circle")
                }
                Button {
                    isEditingItems.toggle()
                } label: {
                    Label(isEditingItems ? "Finish Editing Items" : "Edit Items",
                          systemImage: isEditingItems ? "checkmark.circle" : "pencil.circle")
                }
                Divider()
            }

            Button {
                currentSort = .byName
                sortByName()
            } label: {
                Label("Sort by Name", systemImage: "textformat")
            }

            Button {
                currentSort = .byPrice
                sortByPrice()
            } label: {
                Label("Sort by Price", systemImage: "dollarsign")
            }

            Divider()

            Button(role: .none) {
                markAllDone()
            } label: {
                Label("Mark All Done", systemImage: "checkmark.circle")
            }
        } label: {
            Label(label, systemImage: icon)
        }
    }
}


#Preview {
    ItemsHeaderPreview()
}

fileprivate struct ItemsHeaderPreview: View {
    @State private var isEditingItems: Bool = false
    @State private var currentSort: SortKind = .byName
    
    var body: some View {
        ItemsHeader(isEditingItems: $isEditingItems, currentSort: $currentSort, addItem: {}, sortByName: {}, sortByPrice: {}, markAllDone: {})
    }
}
