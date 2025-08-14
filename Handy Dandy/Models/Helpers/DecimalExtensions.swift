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
