//
//  ShoppingListDetailsSection.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/13/25.
//

import SwiftUI

struct ShoppingListDetailsSection: View {
    @Binding var draft: DraftShoppingList
    
    var body: some View {
        Section("Details") {
            TextField("Name", text: $draft.name)
            Button {
                onPlacePicked()
            } label: {
                HStack {
                    Text("Location")
                    Spacer()
                    
                    if let place = draft.place {
                        Text(place.displayName).foregroundStyle(.secondary)
                    } else {
                        Text("Add Location").foregroundStyle(.secondary)
                    }
                    
                    Image(systemName: "chevron.right")
                }
            }
            
            TextField("Notes", text: $draft.notes.orEmpty)
            HStack {
                LabeledContent("Budget") {
                    CurrencyTextField(value: $draft.plannedBudget, currencyCode: draft.currencyCode.iso)
                }
            }
            
            // Read-only labels
            if let estimate = draft.estimateLabel {
                LabeledContent("Estimate") {
                    Text(estimate)
                        .monospacedDigit()
                }
            }
            
            if let delta = draft.budgetDelta {
                let over = delta > 0
                let absoluteDelta = delta < 0 ? -delta : delta
                let label = MoneyFormat.string(absoluteDelta, code: draft.currencyCode.iso)
                
                HStack {
                    Text("Budget Delta")
                    Spacer()
                    Text(over ? "Over by \(label)" : "Under by \(label)")
                        .foregroundStyle(over ? .red : .green)
                }
            }
        }
    }
    
    private func onPlacePicked() {
        
    }
}

#Preview {
    let shoppingList = ShoppingListShadow()
    let draft = DraftShoppingList(from: shoppingList)
    
    ShoppingListDetailsSectionPreview(draft: draft)
}

fileprivate struct ShoppingListDetailsSectionPreview: View {
    @State var draft: DraftShoppingList
    
    var body: some View {
        ShoppingListDetailsSection(draft: $draft)
    }
}
