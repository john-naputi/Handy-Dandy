//
//  Item.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/11/25.
//

import SwiftData
import Foundation

@Model
final class Item {
    @Attribute(.unique) var id: UUID
    
    // Parent
    var list: ShoppingList?
    
    // Core fields
    var name: String // e.g., "Chicken Thighs", "Yogurt", "Paper Towels"
    var notes: String? // Free text: brand/size/flavor/special notes for this item
    
    // Quantity
    var quantity: Decimal
    var actualQuantity: Decimal
    var unit: MeasurementUnit
    var isDone: Bool // States whether this item has been obtained, or if you are also just done with it in general.
    
    // Category information
    var category: ShoppingCategory
    var customCategory: String?
    
    // Store aisle hints -- e.g., Aisle 12, Meat Aisle, Back Wall Freezer on the Left Size, etc.
    var aisleHint: String?
    
    // Pricing information. Kinda useless without OCR, but I'll see what I can do with it.
    // In general, this is going to be useful for when there are business as well adding it,
    // But I shall see what becomes of it. I'll leave it here for now until I find a use.
    var expectedUnitPrice: Decimal? // This is what the user enters
    var actualUnitPrice: Decimal? // This can be OCR read, but the user can also enter this
    var isTaxable: Bool // Just asks whether the item is taxable
    
    // Pro-tier affordances that would be neat
    var barcode: String? // UPC/EAN as text
    var priority: Int // 0 default; higher means show near the top
    var addedViaVoice: Bool // For Siri/Dictation analytics. Users would see how many items they added via talking!
    
    // Timestamps + local sort
    var sortKey: Int
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(),
         list: ShoppingList? = nil,
         name: String = "",
         notes: String? = nil,
         quantity: Decimal = 1,
         actualQuantity: Decimal = 1,
         unit: MeasurementUnit = .each,
         isDone: Bool = false,
         category: ShoppingCategory = .miscellaneous,
         customCategory: String? = nil,
         aisleHint: String? = nil,
         expectedUnitPrice: Decimal? = nil,
         actualUnitPrice: Decimal? = nil,
         isTaxable: Bool = true,
         barcode: String? = nil,
         priority: Int = 0,
         addedViaVoice: Bool = false,
         sortKey: Int = 0,
         createdAt: Date = .now,
         updatedAt: Date = .now
    ) {
        self.id = id
        self.list = list
        self.name = name
        self.notes = notes
        self.quantity = quantity
        self.actualQuantity = actualQuantity
        self.unit = unit
        self.isDone = isDone
        self.category = category
        self.customCategory = customCategory
        self.aisleHint = aisleHint
        self.expectedUnitPrice = expectedUnitPrice
        self.actualUnitPrice = actualUnitPrice
        self.isTaxable = isTaxable
        self.barcode = barcode
        self.priority = priority
        self.addedViaVoice = addedViaVoice
        self.sortKey = sortKey
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Item {
    var expectedPrice: Decimal? {
        guard let price = expectedUnitPrice else {
            return nil
        }
        
        return price * quantity
    }
    
    var actualPrice: Decimal? {
        guard let price = actualUnitPrice else {
            return nil
        }
        
        return price * actualQuantity
    }
    
    var categoryDisplayName: String {
        if let custom = customCategory?.trimmingCharacters(in: .whitespacesAndNewlines), !custom.isEmpty {
            return custom
        }
        
        return category.name
    }
    
    func lineTotalLabel(currency code: CurrencyCode) -> String? {
        guard let unit = expectedUnitPrice else { return nil }
        let total = unit * quantity
        
        return MoneyFormat.string(total, code: code.iso)
    }
}
