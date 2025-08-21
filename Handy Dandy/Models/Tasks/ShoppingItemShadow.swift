//
//  ShoppingItemShadow.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/20/25.
//

import Foundation

struct ShoppingItemShadow: Identifiable, Equatable {
    var id: UUID
    var name: String
    var notes: String?
    var quantity: Decimal
    var actualQuantity: Decimal?
    var unit: MeasurementUnit
    var isDone: Bool
    var category: ShoppingCategory
    var customCategory: String?
    var aisleHint: String?
    var expectedUnitPrice: Decimal?
    var actualUnitPrice: Decimal?
    var isTaxable: Bool
    var barcode: String?
    var priority: Int
    var addedViaVoice: Bool
    var sortKey: Int
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(),
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
