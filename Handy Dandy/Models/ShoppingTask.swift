//
//  ShoppingTask.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/2/25.
//

import Foundation
import SwiftData

@Model
class ShoppingTask {
    @Attribute(.unique) var id: UUID
    
    var quantity: Double
    var unit: ItemUnit
    var pricePerUnit: Double?
    var note: String?
    
    init(id: UUID = UUID(), quantity: Double = 1, unit: ItemUnit = .unit, pricePerUnit: Double? = nil, note: String? = nil) {
        self.id = id
        self.quantity = quantity
        self.unit = unit
        self.pricePerUnit = pricePerUnit
        self.note = note
    }
}
