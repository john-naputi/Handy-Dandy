//
//  ShoppingTask.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/2/25.
//

import Foundation
import SwiftData

enum ItemUnit: String, Codable, CaseIterable {
    case unit, ounce, pound, gallon, liter, cup, teaspoon, tablespoon
    case pack, box, dozen
    
    var id: Self {
        self
    }
    
    var displayName: String {
        switch self {
        case .unit: return "Unit"
        case .ounce: return "Ounce"
        case .pound: return "Pound"
        case .gallon: return "Gallon"
        case .liter: return "Liter"
        case .cup: return "Cup"
        case .teaspoon: return "Teaspoon"
        case .tablespoon: return "Tablespoon"
        case .pack: return "Pack"
        case .box: return "Box"
        case .dozen: return "Dozen"
        }
    }
}

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
