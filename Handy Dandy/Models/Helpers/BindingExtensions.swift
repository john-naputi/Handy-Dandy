//
//  Binding.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/13/25.
//

import SwiftUI

extension Binding where Value == String {
    init(_ source: Binding<String?>, replacingNilWith empty: String = "") {
        self.init(
            get: { source.wrappedValue ?? empty},
            set: { newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                source.wrappedValue = trimmed.isEmpty ? nil : newValue
            }
        )
    }
}

extension Binding where Value == String? {
    var orEmpty: Binding<String> {
        Binding<String>(
            get: { self.wrappedValue ?? "" },
            set: { self.wrappedValue = $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : $0 }
        )
    }
}
