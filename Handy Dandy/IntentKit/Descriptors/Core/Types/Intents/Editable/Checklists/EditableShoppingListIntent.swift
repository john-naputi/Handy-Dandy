//
//  EditableShoppingListIntent.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/12/25.
//

import Foundation

struct EditableShoppingListIntent: EditableChecklistIntent, ShoppingListIntent {
    var data: ShoppingList
    var mode: EditMode
}
