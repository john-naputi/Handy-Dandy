//
//  DraftItem.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/13/25.
//

import Foundation

struct DraftItem: Identifiable, Equatable {
    var id: UUID
    var name: String
    var notes: String?
    var quantity: Decimal
    var unit: MeasurementUnit
    var priority: Int
    var isDone: Bool
    var category: ShoppingCategory
    var customCategory: String?
    var expectedUnitPrice: Decimal?
    var currencyCode: CurrencyCode?
    
    init(
        id: UUID = .init(),
        name: String = "",
        notes: String? = nil,
        quantity: Decimal = 1,
        unit: MeasurementUnit = .each,
        priority: Int = 0,
        isDone: Bool = false,
        category: ShoppingCategory = .produce,
        customCategory: String? = nil,
        expectedUnitPrice: Decimal? = nil,
        currencyCode: CurrencyCode? = nil
    ) {
        self.id = id
        self.name = name
        self.notes = notes
        self.quantity = quantity
        self.unit = unit
        self.priority = priority
        self.isDone = isDone
        self.category = category
        self.customCategory = customCategory
        self.expectedUnitPrice = expectedUnitPrice
        self.currencyCode = currencyCode
    }
    
    init(from item: ShoppingItemShadow, currencyCode: CurrencyCode) {
        self.id = item.id
        self.name = item.name
        self.notes = item.notes
        self.quantity = item.quantity
        self.unit = item.unit
        self.priority = item.priority
        self.isDone = item.isDone
        self.category = item.category
        self.customCategory = item.customCategory
        self.expectedUnitPrice = item.expectedUnitPrice
        self.currencyCode = currencyCode
    }
    
    func lineTotalLabel(currency code: CurrencyCode) -> String? {
        guard let unit = expectedUnitPrice else { return nil }
        let total = unit * quantity
        
        return MoneyFormat.string(total, code: code.iso)
    }
    
    func duplicate() -> DraftItem {
        var copy = self
        copy.id = UUID()
        copy.isDone = false
        
        return copy
    }
    
    mutating func prepare() {
        self.name = self.name.trimmed()
        self.notes = self.notes?.trimmed()
    }
    
    func finalize(list: ShoppingList) -> Item {
        Item(
            id: self.id,
            list: list,
            name: name.trimmed(),
            notes: notes?.trimmed(),
            quantity: max(0, quantity),
            unit: unit,
            isDone: isDone,
            category: category,
            customCategory: customCategory?.trimmed(),
            expectedUnitPrice: expectedUnitPrice.nonNegative,
            priority: priority,
            sortKey: nextSortKey(for: list),
            createdAt: .now,
            updatedAt: .now
        )
    }
    
    func apply(to target: Item, for mode: InteractionMode) {
        target.name = name.trimmed()
        target.notes = notes?.trimmed()
        target.quantity = max(0, quantity)
        target.unit = unit
        target.isDone = isDone
        target.category = category
        target.customCategory = customCategory?.trimmed()
        target.expectedUnitPrice = expectedUnitPrice.nonNegative
        target.priority = priority
        
        if mode == .create {
            target.createdAt = .now
        }
        
        target.updatedAt = .now
    }
    
    private func nextSortKey(for list: ShoppingList) -> Int {
        (list.items.map(\.sortKey).max() ?? -1) + 1
    }
}
