//
//  Item.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/10/25.
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
final class Item {
    @Attribute(.unique) var id: UUID
    var name: String
    var brand: String?
    var barcode: String?
    var quantity: Double?
    var unit: String?
    var note: String?
    var place: Place?
    
    init(
        id: UUID = UUID(),
        name: String = "",
        brand: String? = nil,
        barcode: String? = nil,
        quantity: Double? = nil,
        unit: String? = nil,
        note: String? = nil,
        place: Place? = nil
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.barcode = barcode
        self.quantity = quantity
        self.unit = unit
        self.note = note
        self.place = place
    }
}
