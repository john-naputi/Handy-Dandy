//
//  ShoppingListHeader.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/15/25.
//

import SwiftUI

struct ShoppingListHeader: View {
    let list: ShoppingList
    var onTapBudget: (() -> Void)? = nil
    var onTapTotal: (() -> Void)? = nil
    
    private var iso: String {
        list.currencyCode.iso
    }
    
    private var estimate: Decimal {
        list.items.reduce(0) { $0 + ($1.expectedPrice ?? 0 )}
    }
    
    private var displayedTotal: Decimal {
        list.manualActualTotal ?? estimate
    }
    
    private var totalLabel: String {
        list.manualActualTotal == nil ? "Estimate" : "Actual Spent"
    }
    
    private var totalIcon: String {
        list.manualActualTotal == nil ? "cart" : "receipt"
    }
    
    private var deltaRaw: Decimal {
        displayedTotal - (list.plannedBudget ?? 0)
    }
    
    private var deltaAbs: Decimal {
        abs(deltaRaw)
    }
    
    private var isOverOrEqual: Bool {
        deltaRaw >= 0
    }
    
    private var deltaTint: Color {
        isOverOrEqual ? .green : .orange
    }
    
    private var deltaAxLabel: String {
        "Difference"
    }
    
    private var deltaAxValue: String {
        isOverOrEqual
        ? "Over budget by \(MoneyFormat.string(from: deltaAbs, code: iso))"
        : "Under budget by \(MoneyFormat.string(from: deltaAbs, code: iso))"
    }
    
    private var deltaIcon: String {
        isOverOrEqual ? "arrow.up.right" : "arrow.up.right"
    }
    
    private var budgetValue: String? {
        list.plannedBudget.map { MoneyFormat.string(from: $0, code: iso )}
    }
    
    private var budgetDisplay: String {
        budgetValue ?? "Tap to set"
    }
    
    private var budgetTint: Color {
        budgetValue == nil ? .secondary : .primary
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SegmentedStatHeader(segments: [
                .init(
                    title: "Budget",
                    icon: "pencil",
                    value: budgetDisplay,
                    tint: budgetTint,
                    isTappable: true,
                    axLabel: "Budget",
                    axValue: budgetValue ?? "Not Set",
                    axHint: "Double-tap to edit the budget"
                ),
                .init(
                    title: "Estimate",
                    icon: "pencil",
                    value: MoneyFormat.string(from: displayedTotal, code: iso),
                    tint: .primary,
                    isTappable: true,
                    axLabel: totalLabel,
                    axValue: MoneyFormat.string(from: displayedTotal, code: iso),
                    axHint: "Double-tap to edit the \(totalLabel.lowercased())"
                ),
                .init(
                    title: "Difference",
                    icon: deltaIcon,
                    value: MoneyFormat.string(from: deltaAbs, code: iso),
                    tint: deltaTint,
                    axLabel: deltaAxLabel,
                    axValue: deltaAxValue
                )
            ], onTap: { index in
                switch index {
                case 0: onTapBudget?()
                case 1: onTapTotal?()
                default: break
                }
            })
            .padding(.vertical, 8)
            .listRowInsets(.init())
            .animation(.easeInOut, value: displayedTotal)
            .animation(.easeInOut, value: deltaTint)
        }
    }
}

#Preview {
    let list = ShoppingList(title: "Costco")
    ShoppingListHeader(list: list)
}
