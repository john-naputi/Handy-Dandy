//
//  DraftShoppingList.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/13/25.
//

struct DraftShoppingList {
    var name: String
    var notes: String?
    var items: [Item]
    
    init(from shoppingList: ShoppingList) {
        self.name = shoppingList.title
        self.notes = shoppingList.notes
        self.items = shoppingList.items
    }
}
