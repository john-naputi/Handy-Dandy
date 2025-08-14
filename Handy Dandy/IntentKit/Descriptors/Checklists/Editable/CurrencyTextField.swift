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
    
    @State private var text: String = ""
    
    private var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        
        return formatter
    }
    
    var body: some View {
        TextField("0", text: $text)
            .keyboardType(.decimalPad)
            .onAppear { syncFromValue() }
            .onChange(of: value) { _, _ in
                syncFromValue()
            }
            .onChange(of: text) { old, new in
                let cleaned = new.replacingOccurrences(of: "[^0-9.,-]", with: "", options: .regularExpression)
                if cleaned.isEmpty {
                    value = nil
                } else if let number = formatter.number(from: cleaned) {
                    value = number.decimalValue
                }
            }
    }
    
    private func syncFromValue() {
        if let v = value {
            text = formatter.string(from: NSDecimalNumber(decimal: v)) ?? ""
        } else {
            text = ""
        }
    }
}

#Preview {
    let shoppingList = ShoppingList()
    let draft = DraftShoppingList(from: shoppingList)
    
    CurrencyTextFieldPreview(draft: draft)
}

fileprivate struct CurrencyTextFieldPreview: View {
    @State var draft: DraftShoppingList
    
    var body: some View {
        CurrencyTextField(value: $draft.plannedBudget, currencyCode: draft.currencyCode.iso)
    }
}
