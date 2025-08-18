//
//  DecimalExtensions.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/13/25.
//

import Foundation

extension Decimal {
    func formattedQuantity(maxFractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = maxFractionDigits
        
        return formatter.string(from: NSDecimalNumber(decimal: self)) ?? "\(self)"
    }
}

extension Optional where Wrapped == Decimal {
    var nonNegative: Decimal? {
        guard let value = self else {
            return nil
        }
        
        return max(0, value)
    }
}
