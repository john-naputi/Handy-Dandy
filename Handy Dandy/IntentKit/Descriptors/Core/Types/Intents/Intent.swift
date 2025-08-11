//
//  BaseDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/29/25.
//

import Foundation
import SwiftUI

enum DescriptorMode {
    case view, edit
}

enum InteractionMode {
    case create
    case edit
}

protocol Intent {
    associatedtype TData
    var data: TData { get }
}

enum EditableIntentOutcome<TDraft> {
    case create(TDraft)
    case update(TDraft)
    case delete(TDraft)
    case cancel
}

enum EditableNumericIntentOutcome<TNumeric> {
    case save(TNumeric)
    case clear
    case cancel
    
    var savedValue: TNumeric? {
        if case let .save(value) = self {
            return value
        }
        
        return nil
    }
    
    func map<U>(_ transform: (TNumeric) -> U) -> EditableNumericIntentOutcome<U> {
        switch self {
        case .save(let value): return .save(transform(value))
        case .clear: return .clear
        case .cancel: return .cancel
        }
    }
}

struct ViewIntent<TData>: Intent {
    let data: TData
}

struct EditableIntent<TData, TDraft>: Intent {
    let data: TData
    let mode: InteractionMode
    let outcome: (EditableIntentOutcome<TDraft>) -> Void
}
