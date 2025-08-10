//
//  DraftTag.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/6/25.
//

import Foundation

struct DraftTag: Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String = ""
    var emoji: String? = nil
    var isSystem: Bool = false
}

extension DraftTag: Hashable {
    var normalizedKey: String {
        self.name.normalizedName
    }
}
