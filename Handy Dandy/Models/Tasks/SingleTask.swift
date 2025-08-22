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
    var notes: String?
    var isDone: Bool
    var dueAt: Date?
    var createdAt: Date
    var updatedAt: Date
    
    var flavor: SingleTaskFlavor
    var payloadData: Data?
    
    @Relationship(deleteRule: .nullify)
    var plan: Plan?
    
    init(uid: UUID = .init(),
         isDone: Bool = false,
         dueAt: Date? = nil,
         createdAt: Date = .now,
         updatedAt: Date = .now,
         flavor: SingleTaskFlavor = .general,
         plan: Plan? = nil) {
        self.uid = uid
        self.isDone = isDone
        self.dueAt = dueAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.flavor = flavor
        self.plan = plan
        self.payloadData = nil
    }
}

extension SingleTask {
    var payload: SingleTaskPayload {
        get {
            if let data = payloadData,
               let decoded = try? JSONDecoder().decode(SingleTaskPayload.self, from: data) {
                return decoded
            }
            
            return .general(.init(text: plan?.title ?? "", notes: notes))
        }
        set {
            payloadData = try? JSONEncoder().encode(newValue)
            switch newValue {
            case .general(let payload):
                notes = payload.notes
            }
            
            flavor = newValue.flavor
        }
    }
}
