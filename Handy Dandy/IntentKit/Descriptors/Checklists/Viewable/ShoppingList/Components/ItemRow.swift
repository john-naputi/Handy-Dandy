//
//  ItemRow.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/15/25.
//

import SwiftUI

struct ItemRow: View {
    let item: Item
    var onToggleDone: (() -> Void)? = nil
    
    private var displayUnitPrice: Decimal? {
        item.isDone ? item.actualUnitPrice ?? item.expectedUnitPrice : item.expectedUnitPrice
    }
    
    private var displayQuantity: Decimal {
        item.isDone ? item.actualQuantity : item.quantity
    }
    
    private var lineTotal: Decimal? {
        if let price = displayUnitPrice {
            return price * displayQuantity
        }
        
        return item.isDone ? item.actualPrice : item.expectedPrice
    }
    
    private var qtyPriceText: String? {
        guard let price = displayUnitPrice else {
            return nil
        }
        
        return "\(plain(displayQuantity)) × \(MoneyFormat.string(from: price))"
    }
    
    private var accessibilitySummary: String {
        var bits: [String] = [item.name.isEmpty ? "Unnamed item" : item.name]
        if let quantityPrice = qtyPriceText {
            bits.append(quantityPrice)
        }
        
        if let total = lineTotal {
            bits.append("Total; \(MoneyFormat.string(from: total))")
        }
        
        return bits.joined(separator: ", ")
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Button(action: {
                onToggleDone?()
            }) {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
                    .accessibilityLabel(item.isDone ? "Mark not done" : "Mark done")
            }
            .buttonStyle(.plain)
            .foregroundStyle(item.isDone ? .green : .secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)
                    .strikethrough(item.isDone, color: .secondary)
                    .foregroundStyle(item.isDone ? .secondary : .primary)
                    .lineLimit(1)
                
                if let note = item.notes, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                if let quantityPrice = qtyPriceText {
                    Text(quantityPrice)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                // Optional aisle/category hint line
                if let hint = item.aisleHint, !hint.isEmpty {
                    Text(hint)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
                
                Spacer(minLength: 8)
                
                Text(lineTotal.map { MoneyFormat.string(from: $0) } ?? "-")
                    .font(.callout.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(item.isDone ? .secondary : .primary)
                    .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilitySummary)
        }
    }
    
    // MARK: - Derived
    private func plain(_ value: Decimal) -> String {
        NSDecimalNumber(decimal: value).stringValue
    }
}

#Preview {
    let item = Item(name: "Eggs", quantity: 1, unit: .dozen)
    ItemRow(item: item)
}
