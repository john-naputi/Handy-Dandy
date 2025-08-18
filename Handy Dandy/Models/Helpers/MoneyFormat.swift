//
//  MoneyFormat.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/13/25.
//

import Foundation

enum MoneyFormat {
    private static let cache = NSCache<NSString, NumberFormatter>()
    
    /// Format a concrete Decimal with a specific ISO 4217 currency code (e.g., "USD", "EUR").
    static func string(
        from value: Decimal,
        code currencyCode: String,
        locale: Locale = .autoupdatingCurrent,
        showCode: Bool = false,
        fractionDigits: Int? = nil
    ) -> String {
        let fmt = FormatterCache.currency(code: currencyCode, locale: locale, showCode: showCode, fractionDigits: fractionDigits)
        return fmt.string(from: value as NSDecimalNumber) ?? NSDecimalNumber(decimal: value).stringValue
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
}
