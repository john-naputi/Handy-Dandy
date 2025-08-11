//
//  EditShoppingListItemSheet.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/13/25.
//

import SwiftUI

fileprivate enum Field {
    case name, quantity, price
}

struct EditShoppingListItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Field?
    
    let mode: InteractionMode
    let currencyCode: CurrencyCode
    @State private var draft: DraftItem
    
    var onSave: (EditableIntentOutcome<DraftItem>) -> Void = { _ in }
    var onCancel: () -> Void = {}
    
    init(
        draft: DraftItem,
        mode: InteractionMode,
        currencyCode: CurrencyCode,
        onSave: @escaping (EditableIntentOutcome<DraftItem>) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.mode = mode
        self.currencyCode = currencyCode
        self.onSave = onSave
        self.onCancel = onCancel
        _draft = State(initialValue: draft)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("Name", text: $draft.name)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled(true)
                        .focused($focused, equals: .name)
                    
                    HStack {
                        Text("Quantity")
                        Spacer()
                        DecimalTextField(value: $draft.quantity)
                            .frame(maxWidth: 120)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Unit", selection: $draft.unit) {
                        ForEach(MeasurementUnit.allCases, id: \.self) { unit in
                            Text(unit.displayName)
                                .tag(unit)
                        }
                    }
                }
                
                Section("Price (Optional)") {
                    LabeledContent("Price") {
                        CurrencyTextField(value: $draft.expectedUnitPrice, currencyCode: currencyCode.iso)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if let total = draft.lineTotalLabel(currency: currencyCode) {
                        LabeledContent("Estimated Line Total") {
                            Text(total).monospacedDigit()
                        }
                    }
                }
            }
            .navigationTitle(mode == .create ? "Add Item" : "Update Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        draft.prepare()
                        mode == .create ? onSave(.create(draft)) : onSave(.update(draft))
                        dismiss()
                    } label: {
                        if mode == .create {
                            Label("Add", systemImage: "plus")
                        } else {
                            Text("Update")
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear {
                focused = .name
            }
        }
    }
}

#Preview {
    let item = Item()
    
    EditShoppingListItemSheet(draft: DraftItem(from: item), mode: .create, currencyCode: .usd, onSave: { _ in }, onCancel: {})
}
