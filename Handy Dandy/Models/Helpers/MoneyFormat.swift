//
//  MoneyFormat.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/13/25.
//

import Foundation

enum MoneyFormat {
    static var cache: [String: NumberFormatter] = [:]
    
    static func string(_ value: Decimal, code currencyCode: String) -> String? {
        let format = cache[currencyCode] ?? {
            let format = NumberFormatter()
            format.numberStyle = .currency
            format.currencyCode = currencyCode
            cache[currencyCode] = format
            
            return format
        }()
        
        return format.string(from: NSDecimalNumber(decimal: value))
    }
}
