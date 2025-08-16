//
//  ShoppingListHeader.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/15/25.
//

import SwiftUI

struct ShoppingListHeader: View {
    let list: ShoppingList
    
    private var iso: String {
        list.currencyCode.iso
    }
    
    private var estimate: Decimal {
        list.items.reduce(0) { $0 + ($1.expectedPrice ?? 0 )}
    }
    
    private var delta: Decimal {
        estimate - (list.plannedBudget ?? 0)
    }
    
    private var axSummary: String {
            let budgetText = list.plannedBudget.map { MoneyFormat.string(from: $0, code: iso) } ?? "not set"
            let estimateText = MoneyFormat.string(from: estimate, code: iso)
            let deltaText = MoneyFormat.string(from: delta, code: iso)
            return "Budget \(budgetText), Estimate \(estimateText), Delta \(deltaText)"
        }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SegmentedStatHeader(segments: [
                .init(
                    title: "Budget",
                    icon: "wallet.pass",
                    value: list.plannedBudget.map { MoneyFormat.string(from: $0, code: iso )} ?? "-",
                    tint: .primary
                ),
                .init(
                    title: "Estimate",
                    icon: "cart",
                    value: MoneyFormat.string(from: estimate, code: iso),
                    tint: .primary
                ),
                .init(
                    title: "Difference",
                    icon: "triangle.righthalf.filled",
                    value: MoneyFormat.string(from: delta, code: iso),
                    tint: (delta <= 0 ? .green : .orange)
                )
            ])
        }
//        VStack(alignment: .leading, spacing: 8) {
//            HStack(spacing: 12) {
//                StatPill(
//                    label: "Budget",
//                    value: list.plannedBudget.map { MoneyFormat.string(from: $0, code: iso )} ?? "-",
//                    style: .info,
//                    icon: "wallet.pass"
//                )
//                StatPill(
//                    label: "Estimate",
//                    value: MoneyFormat.string(from: estimate, code: iso),
//                    style: .neutral,
//                    icon: "cart"
//                )
//                StatPill(
//                    label: "Budget Difference",
//                    value: MoneyFormat.string(from: delta, code: iso),
//                    style: (delta <= 0 ? .good : .warn),
//                    icon: "triangle.righthalf.fill"
//                )
//            }
//        }
//        .padding(.vertical, 8)
//        .listRowInsets(.init())
//        .accessibilityElement(children: .combine)
//        .accessibilityLabel(axSummary)
    }
}

#Preview {
    let list = ShoppingList(title: "Costco")
    ShoppingListHeader(list: list)
}
