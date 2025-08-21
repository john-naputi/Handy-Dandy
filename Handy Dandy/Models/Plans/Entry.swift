//
//  Entry.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/20/25.
//

import Foundation
import SwiftData

@Model
final class Entry {
    @Attribute(.unique) var uid: UUID
    var name: String
    var notes: String?
    var isDone: Bool
    
    var plan: Plan?
    
    init(uid: UUID = .init(), name: String = "", notes: String? = nil, isDone: Bool = false, plan: Plan? = nil) {
        self.uid = uid
        self.name = name
        self.notes = notes
        self.isDone = isDone
        self.plan = plan
    }
}
