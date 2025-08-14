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
    var isDone: Bool
    var category: ShoppingCategory
    var customCategory: String?
    var expectedUnitPrice: Decimal?
    var currencyCode: CurrencyCode?
    
    init(name: String = "", quantity: Decimal = 1, unit: MeasurementUnit = .each) {
        self.id = UUID()
        self.name = name
        self.notes = nil
        self.quantity = quantity
        self.unit = unit
        self.isDone = false
        self.category = .automotive
        self.customCategory = nil
        self.expectedUnitPrice = nil
        self.currencyCode = nil
    }
    
    init(from item: Item) {
        self.id = UUID()
        self.name = item.name
        self.notes = item.notes
        self.quantity = item.quantity
        self.unit = item.unit
        self.isDone = item.isDone
        self.category = item.category
        self.customCategory = item.customCategory
        self.expectedUnitPrice = item.expectedUnitPrice
        self.currencyCode = item.list?.currencyCode
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
    
    mutating func finalize() {
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.notes = notes?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
