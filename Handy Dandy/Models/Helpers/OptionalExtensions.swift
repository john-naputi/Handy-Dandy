//
//  OptionalExtensions.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/21/25.
//

import Foundation

extension Optional where Wrapped == String {
    var trimmedOrNil: String? {
        switch self?.trimmed() {
        case .some(let value) where !value.isEmpty: return value
        default: return nil
        }
    }
}
