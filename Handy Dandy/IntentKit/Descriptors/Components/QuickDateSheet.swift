//
//  QuickDateSheet.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/22/25.
//

import SwiftUI

enum QuickDateMode {
    case date, time, dateTime
    
    var displayedComponents: DatePickerComponents {
        switch self {
        case .date: return .date
        case .time: return .hourAndMinute
        case .dateTime: return [.date, .hourAndMinute]
        }
    }
}

struct QuickDateSheet: View {
    @State private var selected: Date
    var title: String
    var mode: QuickDateMode
    var allowClear: Bool
    var onCancel: () -> Void
    var onSave: (Date) -> Void
    var onClear: () -> Void
    
    init(initial: Date?,
         title: String,
         mode: QuickDateMode,
         allowClear: Bool,
         onCancel: @escaping () -> Void,
         onSave: @escaping (Date) -> Void,
         onClear: @escaping () -> Void) {
        _selected = State(initialValue: initial ?? Date())
        self.title = title
        self.mode = mode
        self.allowClear = allowClear
        self.onCancel = onCancel
        self.onSave = onSave
        self.onClear = onClear
    }
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Select", selection: $selected, displayedComponents: mode.displayedComponents)
                
                if allowClear {
                    Button("Clear Date", role: .destructive, action: onClear)
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel, action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(selected)
                    }
                    .bold()
                }
            }
        }
    }
}

#Preview {
    QuickDateSheet(initial: nil, title: "Due Date", mode: .dateTime, allowClear: true, onCancel: {}, onSave: {_ in }, onClear: {})
}
