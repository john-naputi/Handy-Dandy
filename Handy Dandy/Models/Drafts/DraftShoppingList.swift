//
//  DraftShoppingList.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/13/25.
//

import Foundation

struct DraftShoppingList {
    var name: String
    var notes: String?
    var items: [DraftItem]
    var plannedBudget: Decimal?
    var currencyCode: CurrencyCode
    var estimateLabel: String?
    var budgetDelta: Decimal?
    var place: Place?
    
    init(from shoppingList: ShoppingList) {
        self.name = shoppingList.title
        self.notes = shoppingList.notes
        self.items = []
        self.plannedBudget = shoppingList.plannedBudget
        self.currencyCode = shoppingList.currencyCode
        self.estimateLabel = shoppingList.estimateLabel
        self.budgetDelta = shoppingList.budgetDelta
        self.place = shoppingList.place
        
        for item in shoppingList.items {
            self.items.append(DraftItem(from: item))
        }
    }
}
