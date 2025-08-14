//
//  DecimalTextField.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/13/25.
//

import SwiftUI

struct DecimalTextField: View {
    @Binding var value: Decimal
    var placeholder: String = "0.00"
    var maxFractionDigits: Int = 2
    var allowNegatives: Bool = false
    
    @State private var input: String = ""
    
    private var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = maxFractionDigits
        formatter.usesGroupingSeparator = false
        formatter.locale = .current
        
        return formatter
    }
    
    var body: some View {
        TextField(placeholder, text: $input)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .onAppear { syncFromValue() }
            .onChange(of: value) { _, _ in
                syncFromValue()
            }
            .onChange(of: input) { _, new in
                parseAndAssign(new)
            }
    }
    
    private func syncFromValue() {
        input = formatter.string(from: NSDecimalNumber(decimal: value)) ?? ""
    }
    
    private func parseAndAssign(_ raw: String) {
        let decimalSeparator = formatter.decimalSeparator ?? "."
        let alternativeSeparator = (decimalSeparator == ".") ? "," : "."
        
        // Keep digits, separators, minus
        var separator = raw.replacingOccurrences(of: "[^0-9\\\(decimalSeparator)\\\(alternativeSeparator)-]", with: "", options: .regularExpression)
        separator = separator.replacingOccurrences(of: alternativeSeparator, with: decimalSeparator)
        
        if allowNegatives {
            let isNegative = separator.hasPrefix("-")
            separator = separator.replacingOccurrences(of: "-", with: "")
            if isNegative {
                separator = "-" + separator
            }
        } else {
            separator = separator.replacingOccurrences(of: "-", with: "")
        }
        
        // Allow only a single decimal separator
        if let firstSeparatorRange = separator.range(of: decimalSeparator) {
            let afterFirst = separator[firstSeparatorRange.upperBound...]
            let cleanedAfter = afterFirst.replacingOccurrences(of: decimalSeparator, with: "")
            separator = String(separator[..<firstSeparatorRange.upperBound]) + cleanedAfter
        }
        
        // Parse
        if let number = formatter.number(from: separator) {
            value = number.decimalValue
            input = formatter.string(from: number) ?? separator
        } else if separator.isEmpty || separator == "-" {
            value = 0
            input = separator
        } else {
            // Do not update anything. The user is still typing.
        }
    }
}

#Preview {
    DecimalTextFieldPreview(value: 25)
}

fileprivate struct DecimalTextFieldPreview: View {
    @State var value: Decimal = 25
    
    var body: some View {
        DecimalTextField(value: $value)
    }
}
