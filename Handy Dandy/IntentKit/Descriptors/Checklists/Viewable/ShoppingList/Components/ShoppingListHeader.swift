//
//  ShoppingListHeader.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/15/25.
//

import SwiftUI

struct ShoppingListHeader: View {
    let list: ShoppingList
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(list.title)
                .font(.title2)
                .bold()
            
            HStack(spacing: 12) {
                StatPill(
                    label: "Budget",
                    text: MoneyFormat.string(0, code: list.currencyCode.iso) ?? "",
                    style: StatPillStyle.info,
                    icon: "wallet.pass"
                )
                StatPill(
                    label: "Estimate",
                    text: MoneyFormat.string(list.estimatedFromItems, code: list.currencyCode.iso) ?? "",
                    style: .neutral,
                    icon: "cart"
                )
                StatPill(
                    label: "Budget Difference",
                    text: MoneyFormat.string(list.budgetDelta ?? 0, code: list.currencyCode.iso) ?? "",
                    style: .good,
                    icon: "triangle.righthalf.fill"
                )
            }
        }
    }
}

#Preview {
    let list = ShoppingList(title: "Costco")
    ShoppingListHeader(list: list)
}
