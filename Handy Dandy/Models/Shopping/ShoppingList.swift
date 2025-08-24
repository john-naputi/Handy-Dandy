//
//  ShoppingList.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/11/25.
//

import Foundation
import SwiftData

// MARK: - Enums

enum MeasurementUnit: String, Identifiable, Codable, CaseIterable {
    case each, lb, oz, g, kg, ml, l, dozen, pack, box, bag, bottle, can
    
    var id: Self {
        self
    }
    
    var fullName: String {
        switch self {
        case .each: return "Each"
        case .lb: return "Pounds"
        case .oz: return "Ounces"
        case .g: return "Grams"
        case .kg: return "Kilograms"
        case .ml: return "Milliliters"
        case .l: return "Liters"
        case .dozen: return "Dozen"
        case .pack: return "Pack"
        case .box: return "Box"
        case .bag: return "Bag"
        case .bottle: return "Bottle"
        case .can: return "Can"
        }
    }
    
    var displayName: String {
        switch self {
        case .each: return "each"
        case .lb: return "lb"
        case .oz: return "oz"
        case .g: return "g"
        case .kg: return "kg"
        case .ml: return "ml"
        case .l: return "L"
        case .dozen: return "dozen"
        case .pack: return "pack"
        case .box: return "box"
        case .bag: return "bag"
        case .bottle: return "bottle"
        case .can: return "can"
        }
    }
}

enum ShoppingCategory: String, Identifiable, Codable, CaseIterable {
    case produce, meat, seafood, dairy, bakery, pantry, frozen, beverages, snacks
    case household, cleaning, personalCare, baby, pharmacy, pet, miscellaneous, other
    case sports, outdoors, gardening, electronic, automotive
    
    var id: Self {
        self
    }
    
    var name: String {
        switch self {
        case .produce: return "Produce"
        case .meat: return "Meat"
        case .seafood: return "Seafood"
        case .dairy: return "Dairy"
        case .bakery: return "Bakery"
        case .pantry: return "Pantry"
        case .frozen: return "Frozen"
        case .beverages: return "Beverages"
        case .snacks: return "Snacks"
        case .household: return "Household"
        case .cleaning: return "Cleaning"
        case .personalCare: return "Personal Care"
        case .baby: return "Baby"
        case .pharmacy: return "Pharmacy"
        case .pet: return "Pet"
        case .miscellaneous: return "Miscellaneous"
        case .other: return "Other"
        case .sports: return "Sports"
        case .outdoors: return "Outdoors"
        case .gardening: return "Gardening"
        case .electronic: return "Electronic"
        case .automotive: return "Automotive"
        }
    }
}

enum CurrencyCode: String, Identifiable, Codable, CaseIterable {
    case usd, gbp, eur, jpy, tklira, qar
    
    var id: Self {
        self
    }
    
    var iso: String {
        switch self {
        case .usd:
            return "USD"
        case .gbp:
            return "GBP"
        case .eur:
            return "EUR"
        case .jpy:
            return "JPY"
        case .tklira: // Turkish Lira!!!
            return "TRY"
        case .qar:
            return "QAR" // Qatari Riyal
        }
    }
    
    var displayName: String {
        iso
    }
    
    static func fromCurrentLocale() -> CurrencyCode {
        let code = Locale.current.currency?.identifier ?? "USD"
        switch code {
            case "USD":
            return .usd
        case "GBP":
            return .gbp
        case "EUR":
            return .eur
        case "JPY":
            return .jpy
        case "TRY":
            return .tklira
        case "QAR": return .qar
        default: return .usd
        }
    }
}

// MARK: - ShoppingList

@Model
final class ShoppingList {
    @Attribute(.unique) var id: UUID
    var title: String
    var notes: String?
    
    // Optional: tie a Place (Stage 1/2 of location lifecycle!!!!)
    var place: Place?
    
    // Lighweight metadata
    var isFavorite: Bool // This is for favorite shopping lists!!!
    var plannedDate: Date? // I am thinking that this is tied to the plan, but I'll see
    var currencyCode: CurrencyCode // e.g., "USD". If I can keep this in sync with the local, then this is good
    
    // Budget and price information
    var plannedBudget: Decimal?
    var manualActualTotal: Decimal?
    
    // Sorting and bookkeeping
    var sortKey: Int
    var createdAt: Date
    var updatedAt: Date
    
    // Child items
    @Relationship(deleteRule: .cascade, inverse: \Item.list) var items: [Item]
    
    @Relationship(deleteRule: .nullify)
    var plan: Plan?
    
    init(id: UUID = UUID(),
         title: String = "",
         notes: String? = nil,
         place: Place? = nil,
         isFavorite: Bool = false,
         plannedDate: Date? = nil,
         currencyCode: CurrencyCode = .fromCurrentLocale(),
         plannedBudget: Decimal? = nil,
         manualActualTotal: Decimal? = nil,
         sortKey: Int = 0,
         createdAt: Date = .now,
         updatedAt: Date = .now,
         items: [Item] = [],
         plan: Plan? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.place = place
        self.isFavorite = isFavorite
        self.plannedDate = plannedDate
        self.currencyCode = currencyCode
        self.plannedBudget = plannedBudget
        self.manualActualTotal = manualActualTotal
        self.sortKey = sortKey
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.items = items
        self.plan = plan
    }
}

extension ShoppingList {
    var estimatedFromItems: Decimal {
        items.compactMap { $0.expectedPrice }.reduce(.zero, +)
    }
    
    /// Sum of actual line totals for items that have a price
    var actualSubtotal: Decimal {
        items.compactMap { $0.actualPrice }.reduce(.zero, +)
    }
    
    /// Prefer the single-user entered actual total; else show the computed actual if non-zero
    var actualTotalDisplay: Decimal? {
        manualActualTotal ?? (actualSubtotal == .zero ? nil : actualSubtotal)
    }
    
    /// How many items have an expected price (for confidence UI)
    var pricedItemCount: Int {
        items.filter { $0.expectedPrice != nil }.count
    }
    
    /// 0..1 coverage of priced items
    var pricedCoverage: Double {
        guard !items.isEmpty else {
            return 0
        }
        
        return Double(pricedItemCount) / Double(items.count)
    }
    
    var remainingItemsCount: Int {
        items.filter { !$0.isDone }.count
    }
    
    var budgetDelta: Decimal? {
        guard let budget = plannedBudget else {
            return nil
        }
        
        if manualActualTotal == nil && pricedItemCount == 0 {
            return nil
        }
        
        let comparator = actualTotalDisplay ?? estimatedFromItems
        return comparator - budget
    }
    
    func add(_ item: Item) {
        items.append(item)
        item.list = self
        updatedAt = .now
    }
    
    func remove(_ item: Item) {
        items.removeAll(where: { $0.id == item.id })
        updatedAt = .now
    }
    
    func markItem(_ itemID: UUID, done: Bool) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else {
            return
        }
        
        items[index].isDone = done
        updatedAt = .now
    }
    
    private static var currencyFormatters = [String: NumberFormatter]()
    
    func formatMoney(_ value: Decimal?) -> String? {
        guard let value else {
            return nil
        }
        
        let code = currencyCode.iso
        let formatter = ShoppingList.currencyFormatters[code] ?? {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currencyCode.iso
            ShoppingList.currencyFormatters[code] = formatter
            
            return formatter
        }()
        
        return formatter.string(from: NSDecimalNumber(decimal: value))
    }
}

extension ShoppingList {
    var placeName: String? {
        return place?.displayName
    }
    
    var budgetLabel: String? {
        formatMoney(plannedBudget)
    }
    
    var estimateLabel: String? {
        formatMoney(estimatedFromItems)
    }
    
    var actualLabel: String? {
        formatMoney(actualTotalDisplay)
    }
    
    func clearActuals() {
        manualActualTotal = nil
        items.forEach { $0.actualUnitPrice = nil }
        updatedAt = .now
    }
}
