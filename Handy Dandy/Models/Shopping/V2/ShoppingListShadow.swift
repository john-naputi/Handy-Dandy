//
//  ShoppingListShadow.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/24/25.
//

import Foundation

struct ShoppingListShadow: Equatable {
    private static var currencyFormatters = [String: NumberFormatter]()
    
    let id: UUID
    let title: String
    let notes: String?
    let currencyCode: CurrencyCode
    let budget: Decimal?
    let estimatedFromItems: Decimal
    let actualSubtotal: Decimal
    let manualActualTotal: Decimal?
    let sortKey: Int
    let createdAt: Date
    let updatedAt: Date
    let items: [ShoppingItemShadow]
    
    var actualTotalDisplay: Decimal? {
        manualActualTotal ?? (actualSubtotal == .zero ? nil : actualSubtotal)
    }
    
    var budgetDelta: Decimal? {
        guard let budget else { return nil }
        if manualActualTotal == nil && estimatedFromItems == .zero && actualSubtotal == .zero {
            return nil
        }
        
        let comparator = actualTotalDisplay ?? estimatedFromItems
        return comparator - budget
    }
    
    var budgetLabel: String? {
        formatMoney(budget)
    }
    
    var estimateLabel: String? {
        formatMoney(estimatedFromItems)
    }
    
    var actualLabel: String? {
        formatMoney(actualTotalDisplay)
    }
    
    init(id: UUID = .init(),
         title: String = "",
         notes: String? = nil,
         currencyCode: CurrencyCode = CurrencyCode(rawValue: Locale.current.currency?.identifier ?? CurrencyCode.usd.iso) ?? .usd,
         budget: Decimal? = nil,
         estimatedFromItems: Decimal = .zero,
         actualSubtotal: Decimal = .zero,
         manualActualTotal: Decimal? = nil,
         sortKey: Int = 0,
         createdAt: Date = .now,
         updatedAt: Date = .now,
         items: [ShoppingItemShadow] = []) {
        self.id = id
        self.title = title
        self.notes = notes
        self.currencyCode = currencyCode
        self.budget = budget
        self.estimatedFromItems = estimatedFromItems
        self.actualSubtotal = actualSubtotal
        self.manualActualTotal = manualActualTotal
        self.sortKey = sortKey
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.items = items
    }
    
    func formatMoney(_ value: Decimal?) -> String? {
        guard let value else {
            return nil
        }
        
        let code = currencyCode.iso
        let formatter = ShoppingListShadow.currencyFormatters[code] ?? {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currencyCode.iso
            ShoppingListShadow.currencyFormatters[code] = formatter
            
            return formatter
        }()
        
        return formatter.string(from: NSDecimalNumber(decimal: value))
    }
}
