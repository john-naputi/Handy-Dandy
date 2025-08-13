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
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    let shoppingList = ShoppingList()
    let intent = EditableIntent<ShoppingList, DraftShoppingList>(data: shoppingList, mode: .create) { outcome in }
    EditableShoppingListDescriptor(intent: intent)
}
