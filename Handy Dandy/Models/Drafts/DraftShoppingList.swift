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
    
    func apply(to list: ShoppingList, for mode: InteractionMode) {
        list.title = self.name
        list.notes = self.notes
        list.plannedBudget = self.plannedBudget
        list.currencyCode = self.currencyCode
        list.place = self.place
        list.updatedAt = .now
        
        switch mode {
        case .create:
            // Rebuild items (simple first pass)
            list.items = items.map { draftItem in
                let item = createItem(from: draftItem, using: list)
                
                return item
            }
        case .edit:
            var existingById: [UUID: Item] = Dictionary(uniqueKeysWithValues: list.items.map { ($0.id, $0 )})
            let desiredOrder: [UUID] = items.map(\.id)
            
            // Update or add
            for draft in items {
                if let existing = existingById.removeValue(forKey: draft.id) {
                    // Update in place
                    existing.name = draft.name
                    existing.notes = draft.notes
                    existing.quantity = draft.quantity
                    // Do NOT touch actualQuantity here
                    existing.unit = draft.unit
                    existing.isDone = draft.isDone
                    existing.category = draft.category
                    existing.customCategory = draft.customCategory
                    existing.expectedUnitPrice = draft.expectedUnitPrice
                    existing.priority = draft.priority
                    existing.updatedAt = .now
                } else {
                    let item = createItem(from: draft, using: list)
                }
            }
            
            // Delete anything left in the dictionary as the draft has removed it.
            if !existingById.isEmpty {
                let idsToDelete = Set(existingById.keys)
                list.items.removeAll { idsToDelete.contains($0.id) }
            }
            
            // Reorder to match the draft
            let position = Dictionary(uniqueKeysWithValues: desiredOrder.enumerated().map { ($0.element, $0.offset )})
            list.items.sort { (first, second) in
                let firstPosition = position[first.id] ?? Int.max
                let secondPosition = position[second.id] ?? Int.max
                return firstPosition < secondPosition
            }
        }
    }
    
    private func createItem(from draft: DraftItem, using list: ShoppingList) -> Item {
        let item = Item(
            id: draft.id,
            list: list,
            name: draft.name,
            notes: draft.notes,
            quantity: draft.quantity,
            actualQuantity: draft.quantity, // I didn't set this. Not sure if it should be set from the draft as this would be the final value.
            unit: draft.unit,
            isDone: draft.isDone,
            category: draft.category,
            customCategory: draft.customCategory,
            aisleHint: nil,
            expectedUnitPrice: draft.expectedUnitPrice,
            actualUnitPrice: nil,
            isTaxable: true,
            priority: draft.priority,
            sortKey: 0
        )
        
        item.createdAt = .now
        item.updatedAt = .now
        
        return item
    }
}
