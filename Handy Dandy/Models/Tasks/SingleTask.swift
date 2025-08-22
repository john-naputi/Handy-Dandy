//
//  SingleTask.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/21/25.
//

import Foundation
import SwiftData

@Model
final class SingleTask {
    @Attribute(.unique) var uid: UUID
    var title: String
    var isDone: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(uid: UUID = UUID(), title: String = "", isDone: Bool = false, createdAt: Date = .now, updatedAt: Date = .now) {
        self.uid = uid
        self.title = title
        self.isDone = isDone
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
