//
//  MoneyFormat.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/13/25.
//

import Foundation

enum MoneyFormat {
    static var cache: [String: NumberFormatter] = [:]
    private static let cache2 = NSCache<NSString, NumberFormatter>()
    
    /// Format a concrete Decimal with a specific ISO 4217 currency code (e.g., "USD", "EUR").
    static func string(
        from value: Decimal,
        code currencyCode: String,
        locale: Locale = .autoupdatingCurrent,
        showCode: Bool = false,
        fractionDigits: Int? = nil
    ) -> String {
        let fmt = formatter(code: currencyCode, locale: locale, showCode: showCode, fractionDigits: fractionDigits)
        if let text = fmt.string(from: NSDecimalNumber(decimal: value)) {
            return text
        }
        
        // Fallback: plain number if formatter somehow fails
        return NSDecimalNumber(decimal: value).stringValue
    }
    
    /// Convenience for optional Decimals (avoids if-let at call sites).
    static func string(
        _ value: Decimal?,
        code currencyCode: String,
        placeholder: String = "-",
        locale: Locale = .autoupdatingCurrent,
        showCode: Bool = false,
        fractionDigits: Int? = nil
    ) -> String {
        guard let value else {
            return placeholder
        }
        
        return string(from: value, code: currencyCode, locale: locale, showCode: showCode, fractionDigits: fractionDigits)
    }
    
    /// Convenience that uses the device’s current currency (good for generic totals).
    static func string(
        from value: Decimal,
        locale: Locale = .autoupdatingCurrent,
        showCode: Bool = false,
        fractionDigits: Int? = nil
    ) -> String {
        let code = (locale as NSLocale).object(forKey: .currencyCode) as? String ?? "USD"
        return string(from: value, code: code, locale: locale, showCode: showCode, fractionDigits: fractionDigits)
    }
    
    private static func formatter(
        code: String,
        locale: Locale,
        showCode: Bool,
        fractionDigits: Int?
    ) -> NumberFormatter {
        let key = "\(code)|\(locale.identifier)|\(showCode ? "code" : "symbol")|\(fractionDigits.map(String.init) ?? "auto")" as NSString
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.currencyCode = code
        
        if let digits = fractionDigits {
            formatter.minimumFractionDigits = digits
            formatter.maximumFractionDigits = digits
        }
        
        formatter.roundingMode = .halfUp
        
        if showCode {
            formatter.currencySymbol = code + " "
        }
        
        cache2.setObject(formatter, forKey: key)
        
        return formatter
    }
    
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
