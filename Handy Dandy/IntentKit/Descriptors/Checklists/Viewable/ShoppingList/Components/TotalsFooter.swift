//
//  TotalsFooter.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/15/25.
//

import SwiftUI

struct TotalsFooter: View {
    let estimate: Decimal
    let budget: Decimal?
    let delta: Decimal
    
    private var accessibilityLabel: String {
        var bits = ["Estimate \(MoneyFormat.string(from: estimate))"]
        if let budget {
            bits.append("Budget \(MoneyFormat.string(from: budget))")
        }
        bits.append("Delta \(MoneyFormat.string(from: delta))")
        
        return bits.joined(separator: ", ")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider().opacity(0.5)
            
            HStack(spacing: 12) {
                StatPill(
                    label: "Estimate",
                    value: MoneyFormat.string(from: estimate),
                    style: .neutral,
                    icon: "cart"
                )
                
                if let budget {
                    StatPill(
                        label: "Budget",
                        value: MoneyFormat.string(from: budget),
                        style: .info,
                        icon: "wallet.pass")
                }
                
                StatPill(label: "Price Delta",
                         value: MoneyFormat.string(from: delta),
                         style: delta <= 0 ? .good : .warn,
                         icon: "triangle.righthalf.filled",
                         compact: true)
            }
            
            if let budget, delta > 0 {
                Text("Over budget by \(MoneyFormat.string(from: delta)).")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else if let budget, delta < 0 {
                Text("Under budget by \(MoneyFormat.string(from: delta)).")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    let estimate = Decimal(100)
    let budget = Decimal(70)
    let delta = Decimal(25)
    TotalsFooter(estimate: estimate, budget: budget, delta: delta)
}
