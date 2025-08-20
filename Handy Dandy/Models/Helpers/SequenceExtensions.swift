//
//  SequenceExtensions.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/18/25.
//

import Foundation

extension Sequence {
    @inlinable
    func count(where predicate: (Element) throws -> Bool) rethrows -> Int {
        try reduce(0) { try predicate($1) ? $0 + 1 : $0 }
    }
}
