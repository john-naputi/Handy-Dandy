//
//  CurrencyTextField.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/13/25.
//

import SwiftUI

struct CurrencyTextField: View {
    @Binding var value: Decimal?
    let currencyCode: String
    var allowNegative: Bool = false
    var strictTyping: Bool = false
    var clearsZeroOnFocus: Bool = false
    
    @State private var text: String = ""
    @State private var lastValid: Decimal? = nil
    @State private var lastValidText: String = ""
    @State private var lastEditedText: String? = nil
    @FocusState private var focused: Bool
    
    private var currencyFormatter: NumberFormatter {
        FormatterCache.currency(code: currencyCode)
    }
    
    private var decimalFormatter: NumberFormatter {
        FormatterCache.decimal()
    }
    
    var body: some View {
        TextField("0", text: $text)
            .keyboardType(allowNegative ? .numbersAndPunctuation : .decimalPad)
            .focused($focused)
            .monospacedDigit()
            .textInputAutocapitalization(.never)
            .accessibilityLabel("Amount")
            .accessibilityValue(text)
            .autocorrectionDisabled(true)
            .onAppear {
                syncFromValue(displayMode: true)
                captureAsLastValid()
            }
            .onChange(of: currencyCode) { _, _ in
                syncFromValue(displayMode: !focused)
                captureAsLastValid()
            }
            .onChange(of: value) { _, _ in
                if !focused {
                    syncFromValue(displayMode: true)
                    captureAsLastValid()
                }
            }
            .onChange(of: focused) { _, isFocused in
                if isFocused {
                    enterEditMode()
                } else {
                    if !parses(text) {
                        restoreLastValidVisual()
                    }
                    syncFromValue(displayMode: true)
                }
            }
            .onChange(of: text) { old, new in
                if new.isEmpty {
                    value = nil
                    lastValid = nil
                    lastValidText = ""
                    lastEditedText = nil
                    return
                }
                
                let parsedNumber = currencyFormatter.number(from: new)
                ?? decimalFormatter.number(from: new)
                ?? FormatterCache.decimal(grouping: true).number(from: new)
                
                if let number = parsedNumber {
                    let decimal = number.decimalValue
                    let clamped = allowNegative ? decimal : max(0, decimal)
                    value = clamped
                    
                    // Store last good parase + its current visual
                    lastValid = clamped
                    lastValidText = new
                    lastEditedText = new
                    return
                }
                
                // Allowed intermediates (let user keep typing): "-", ".", ",", "-0.", "0,"
                if isIntermediate(new) {
                    // leave `value` as-is; don't clobber user typing
                    return
                }

                // Truly invalid: either revert immediately or defer till blur
                if strictTyping {
                    restoreLastValidVisual()
                } else {
                    // permissive: do nothing; we'll snap on blur
                }
            }
    }
    
    private func enterEditMode() {
        if clearsZeroOnFocus, let v = value, v == 0 {
            text = ""
            return
        }
        
        // If the user last typed something that parses to our current value, show it verbatim.
        if let edited = lastEditedText,
           let parsed = decimalFormatter.number(from: edited)
            ?? FormatterCache.decimal(grouping: true).number(from: edited)
            ?? currencyFormatter.number(from: edited),
           parsed.decimalValue == (value ?? 0) {
            text = edited
            return
            
        }
        
        // Fallback: show plain numeric edit string
        syncFromValue()
    }
    
    private func syncFromValue(displayMode: Bool = false) {
        guard let v = value else {
            text = ""
            return
        }
        
        let number = NSDecimalNumber(decimal: v)
        text = displayMode
        ? currencyFormatter.string(from: number) ?? ""
        : decimalFormatter.string(from: number) ?? ""
    }
    
    private func parses(_ value: String) -> Bool {
        currencyFormatter.number(from: value) != nil ||
        decimalFormatter.number(from: value) != nil ||
        FormatterCache.decimal(grouping: true).number(from: value) != nil
    }
    
    private func isIntermediate(_ value: String) -> Bool {
        let decimalSeparator = decimalFormatter.decimalSeparator ?? "."
        if value == "-" { return allowNegative }
        if value == decimalSeparator { return true }
        if value == "0\(decimalSeparator)" { return true }        // "0.", "0,"
        if allowNegative && (value == "-0\(decimalSeparator)" || value == "-\(decimalSeparator)") { return true }
        
        return false
    }
    
    private func captureAsLastValid() {
        lastValid = value
        lastValidText = text
    }
    
    private func restoreLastValidVisual() {
        if let v = lastValid {
            let number = NSDecimalNumber(decimal: v)
            text = focused
            ? (decimalFormatter.string(from: number) ?? lastValidText)
            : (currencyFormatter.string(from: number) ?? lastValidText)
            
            value = v
        } else {
            text = ""
            value = nil
        }
    }
}

extension CurrencyTextField {
    init(
        value: Binding<Decimal>,
        currencyCode: String,
        allowNegative: Bool = false,
        strictTyping: Bool = false,
        clearZeroOnFocus: Bool = false) {
            self._value = Binding<Decimal?>(
                get: { Optional(value.wrappedValue) },
                set: { value.wrappedValue = $0 ?? 0 }
            )
            self.currencyCode = currencyCode
            self.allowNegative = allowNegative
            self.strictTyping = strictTyping
            self.clearsZeroOnFocus = clearZeroOnFocus
    }
}

#Preview {
    let shoppingList = ShoppingListShadow()
    let draft = DraftShoppingList(from: shoppingList)
    
    CurrencyTextFieldPreview(draft: draft)
}

fileprivate struct CurrencyTextFieldPreview: View {
    @State var draft: DraftShoppingList
    
    var body: some View {
        CurrencyTextField(value: $draft.plannedBudget, currencyCode: draft.currencyCode.iso)
    }
}
