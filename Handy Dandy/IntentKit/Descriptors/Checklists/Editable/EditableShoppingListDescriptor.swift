//
//  EditableShoppingListDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/13/25.
//

import SwiftUI

fileprivate enum ItemSheetRoute: Identifiable {
    case add
    case edit(id: UUID)

    var id: String {
        switch self {
        case .add:            return "add"
        case .edit(let id):   return "edit-\(id)"
        }
    }
}

struct EditableShoppingListDescriptor: View {
    @Environment(\.dismiss) private var dismiss

    // Designated inputs (bubble decisions to container)
    let mode: InteractionMode        // .create / .edit
    let onCancel: () -> Void
    let onSave: (DraftShoppingList) -> Void

    // Local editing state
    @State private var draft: DraftShoppingList
    @State private var itemSheet: ItemSheetRoute?
    @State private var detent: PresentationDetent = .medium

    // Designated initializer
    init(initial: DraftShoppingList,
         mode: InteractionMode,
         onCancel: @escaping () -> Void,
         onSave: @escaping (DraftShoppingList) -> Void) {
        _draft = State(initialValue: initial)
        self.mode = mode
        self.onCancel = onCancel
        self.onSave = onSave
    }

    // Convenience for callers that only have a shadow (e.g., previews)
    init(shadow: ShoppingListShadow,
         mode: InteractionMode = .edit,
         onCancel: @escaping () -> Void = {},
         onSave: @escaping (DraftShoppingList) -> Void = { _ in }) {
        _draft = State(initialValue: DraftShoppingList(from: shadow))
        self.mode = mode
        self.onCancel = onCancel
        self.onSave = onSave
    }

    var body: some View {
        Form {
            ShoppingListDetailsSection(draft: $draft)

            ShoppingListItemsSection(
                draft: $draft,
                onAddTapped: { itemSheet = .add },
                onEditTapped: { id in itemSheet = .edit(id: id) }
            )
        }
        .navigationTitle(mode == .create ? "New Shopping List" : "Edit Shopping List")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    onCancel()
                    dismiss()
                }
                .accessibilityLabel("Cancel")
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(mode == .create ? "Add" : "Save") {
                    onSave(draft)
                    dismiss()
                }
                .accessibilityLabel(mode == .create ? "Add list" : "Save changes")
                .bold()
            }
        }
        .sheet(item: $itemSheet, onDismiss: { itemSheet = nil }) { route in
            switch route {
            case .add:
                EditShoppingListItemSheet(
                    draft: DraftItem(),
                    mode: .create,
                    currencyCode: draft.currencyCode,
                    onSave: { outcome in
                        if case let .create(itemDraft) = outcome {
                            var copy = itemDraft
                            copy.prepare()
                            draft.items.append(copy)
                        }
                    },
                    onCancel: {}
                )
                .presentationDetents([.medium, .large])

            case .edit(let id):
                if let index = draft.items.firstIndex(where: { $0.id == id }) {
                    EditShoppingListItemSheet(
                        draft: draft.items[index],
                        mode: .edit,
                        currencyCode: draft.currencyCode,
                        onSave: { outcome in
                            if case let .update(item) = outcome {
                                var copy = item
                                copy.prepare()
                                if let i = draft.items.firstIndex(where: { $0.id == copy.id }) {
                                    draft.items[i] = copy
                                } else {
                                    draft.items.append(copy)
                                }
                            }
                        },
                        onCancel: {}
                    )
                    .presentationDetents([.medium, .large], selection: $detent)
                    .onAppear { detent = .large }
                }
            }
        }
    }
}
