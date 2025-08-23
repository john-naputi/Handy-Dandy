//
//  TaskItem.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/18/25.
//

import SwiftData
import Foundation

@Model
final class TaskItem {
    @Attribute(.unique) var taskItemId: UUID
    var text: String
    var isDone: Bool
    var createdAt: Date
    var updatedAt: Date
    var sortIndex: Int
    
    // MARK: Inline V1 shopping specifics
    var quantity: Double?
    var unitRaw: String? // Maps to MeasurementUnit
    var expectedUnitPrice: Decimal?
    var actualUnitPrice: Decimal?
    
    @Relationship(deleteRule: .nullify)
    var list: TaskList?
    
    init(id: UUID = UUID(),
         text: String = "",
         isDone: Bool = false,
         createdAt: Date = .now,
         updatedAt: Date = .now,
         sortIndex: Int = 0,
         
         // MARK: Inline V1 shopping specifics
         quantity: Double? = nil,
         unitRaw: String? = nil,
         expectedUnitPrice: Decimal? = nil,
         actualUnitPrice: Decimal? = nil
    ) {
        self.taskItemId = id
        self.text = text
        self.isDone = isDone
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sortIndex = sortIndex
        
        // MARK: Inline V1 shopping specifics
        self.quantity = quantity
        self.unitRaw = unitRaw
        self.expectedUnitPrice = expectedUnitPrice
        self.actualUnitPrice = actualUnitPrice
    }
    
    #if DEBUG
    func debugString() -> String {
        "TaskItem(taskItemId=\(taskItemId), text=\(text), isDone=\(isDone), createdAt=\(createdAt), updatedAt=\(updatedAt), sortIndex=\(sortIndex))"
    }
    #endif
}

// MARK: Inline V1 shopping specifics
extension TaskItem {
    var expectedPrice: Decimal? {
        guard let q = quantity, let eup = expectedUnitPrice else {
            return nil
        }
        
        return Decimal(q) * eup
    }
    
    var actualPrice: Decimal? {
        guard let q = quantity, let aup = actualUnitPrice else {
            return nil
        }
        
        return aup * Decimal(q)
    }
    
    var unit: MeasurementUnit? {
        unitRaw.flatMap { MeasurementUnit(rawValue: $0 )}
    }
}
