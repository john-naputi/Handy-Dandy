//
//  EditableManualTotalSheet.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/16/25.
//

import SwiftUI

struct EditableManualTotalSheet: View {
    let currencyCode: CurrencyCode
    let estimate: Decimal
    let existing: Decimal?
    let onOutcome: (EditableNumericIntentOutcome<Decimal>) -> Void
    let onCancel: () -> Void
    
    @State private var amount: Decimal
    @FocusState private var focused: Bool
    
    init(currencyCode: CurrencyCode,
         estimate: Decimal,
         existing: Decimal?,
         onOutcome: @escaping (EditableNumericIntentOutcome<Decimal>) -> Void,
         onCancel: @escaping () -> Void) {
        self.currencyCode = currencyCode
        self.estimate = estimate
        self.existing = existing
        self.onOutcome = onOutcome
        self.onCancel = onCancel
        _amount = State(initialValue: existing ?? 0)
    }
    
    private var isUnchanged: Bool {
        existing.map { $0 == amount } ?? false
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Final Receipt Total") {
                    CurrencyTextField(
                        value: $amount,
                        currencyCode: currencyCode.iso,
                        clearZeroOnFocus: true
                    )
                    .focused($focused)
                    
                    HStack {
                        Button {
                            amount = estimate
                        } label: {
                            Label("Use Estimate", systemImage: "cart")
                        }
                        
                        Spacer()
                        
                        if existing != nil {
                            Button(role: .destructive) {
                                onOutcome(.clear)
                            } label: {
                                Label("Clear Entered Total", systemImage: "arrow.uturn.backward")
                            }
                        }
                    }
                    .buttonStyle(.borderless)
                }
            }
            .navigationTitle(existing == nil ? "Set Actual Total" : "Edit Actual Total")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onOutcome(.save(max(0, amount)))
                    }
                    .disabled(isUnchanged)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focused = false
                    }
                }
            }
            .onAppear { focused = true }
            .presentationDetents([.height(220), .medium])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    EditableManualTotalSheet(currencyCode: .usd, estimate: 100, existing: nil, onOutcome: { _ in
        // Placeholder for preview
    }, onCancel: {
        // Placeholder for preview
    })
}
