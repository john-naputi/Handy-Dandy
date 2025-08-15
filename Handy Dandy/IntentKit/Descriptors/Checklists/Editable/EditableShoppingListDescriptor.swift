//
//  EditableShoppingListDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/13/25.
//

import SwiftUI

struct EditableShoppingListDescriptor: View {
    let intent: EditableIntent<ShoppingList, DraftShoppingList>
    @State private var draft: DraftShoppingList
    
    init(intent: EditableIntent<ShoppingList, DraftShoppingList>) {
        self.intent = intent
        _draft = State(initialValue: DraftShoppingList(from: intent.data))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                ShoppingListDetailsSection(draft: $draft)
                ShoppingListItemsSection(draft: $draft)
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
                    } label: {
                        Text("Cancel")
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
    }
}

#Preview {
    let shoppingList = ShoppingList()
    let intent = EditableIntent<ShoppingList, DraftShoppingList>(data: shoppingList, mode: .create) { outcome in }
    EditableShoppingListDescriptor(intent: intent)
}
