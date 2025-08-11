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
        case .add: return "add"
        case .edit(let id): return "edit-\(id)"
        }
    }
}

struct EditableShoppingListDescriptor: View {
    @Environment(\.dismiss) private var dismiss
    
    let intent: EditableIntent<ShoppingList, DraftShoppingList>
    @State private var draft: DraftShoppingList
    @State private var itemSheet: ItemSheetRoute? = nil
    @State private var detent: PresentationDetent = .medium
    
    init(intent: EditableIntent<ShoppingList, DraftShoppingList>) {
        self.intent = intent
        _draft = State(initialValue: DraftShoppingList(from: intent.data))
    }
    
    var body: some View {
        Form {
            ShoppingListDetailsSection(draft: $draft)
            ShoppingListItemsSection(draft: $draft, onAddTapped: {
                itemSheet = .add
            }, onEditTapped: { id in
                itemSheet = .edit(id: id)
            })
        }
        .navigationTitle(intent.mode == .create ? "New Shopping List" : "Edit Shopping List")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onCommit()
                } label: {
                    Text(intent.mode == .create ? "Add" : "Save")
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    intent.outcome(.cancel)
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
        }
        .sheet(item: $itemSheet, onDismiss: { itemSheet = nil }) { route in
            switch route {
            case .add:
                EditShoppingListItemSheet(draft: DraftItem(), mode: .create, currencyCode: self.draft.currencyCode, onSave: { outcome in
                    if case let .create(itemDraft) = outcome {
                        draft.items.append(itemDraft)
                    }
                }, onCancel: {})
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                
            case .edit(let id):
                if let index = draft.items.firstIndex(where: { $0.id == id }) {
                    EditShoppingListItemSheet(draft: draft.items[index], mode: .edit, currencyCode: draft.currencyCode, onSave: { outcome in
                        if case let .update(item) = outcome {
                            if let updatedIndex = draft.items.firstIndex(where: { $0.id == item.id }) {
                                draft.items[updatedIndex] = item
                            } else {
                                draft.items.append(item)
                            }
                        }
                    }, onCancel: {})
                    .presentationDetents([.medium, .large], selection: $detent)
                    .presentationDragIndicator(.visible)
                    .onAppear {
                        detent = .large
                    }
                }
            }
        }
    }
    
    private func onCommit() {
        if intent.mode == .create {
            intent.outcome(.create(draft))
        } else if intent.mode == .edit {
            intent.outcome(.update(draft))
        }
        
        dismiss()
    }
}

#Preview {
    let shoppingList = ShoppingList()
    let intent = EditableIntent<ShoppingList, DraftShoppingList>(data: shoppingList, mode: .create) { outcome in }
    EditableShoppingListDescriptor(intent: intent)
}
