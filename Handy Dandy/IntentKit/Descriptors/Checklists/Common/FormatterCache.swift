//
//  FormatterCache.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/16/25.
//

import Foundation

enum FormatterCache {
    private static let currencyCache = NSCache<NSString, NumberFormatter>()
    private static let decimalCache = NSCache<NSString, NumberFormatter>()
    
    static func currency(
        code: String,
        locale: Locale = .autoupdatingCurrent,
        showCode: Bool = false,
        fractionDigits: Int? = nil
    ) -> NumberFormatter {
        let key = "\(code)|\(locale.identifier)|\(showCode ? "code" : "symbol")|\(fractionDigits.map(String.init) ?? "auto")" as NSString
        if let cached = currencyCache.object(forKey: key) {
            return cached
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.currencyCode = code
        formatter.generatesDecimalNumbers = true
        formatter.usesGroupingSeparator = true
        formatter.roundingMode = .halfUp
        
        if let digits = fractionDigits {
            formatter.minimumFractionDigits = digits
            formatter.maximumFractionDigits = digits
        }
        
        if showCode {
            // e.g. "USD 12.34
            formatter.currencySymbol = code + " "
        }
        
        currencyCache.setObject(formatter, forKey: key)
        return formatter
    }
    
    static func decimal(
        locale: Locale = .autoupdatingCurrent,
        grouping: Bool = false
    ) -> NumberFormatter {
        let key = "\(locale.identifier)|g:\(grouping)" as NSString
        if let cached = decimalCache.object(forKey: key) { return cached }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        formatter.generatesDecimalNumbers = true
        formatter.usesGroupingSeparator = grouping
        decimalCache.setObject(formatter, forKey: key)
        return formatter
    }
}
