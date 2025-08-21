//
//  TaskListItemShadow.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/20/25.
//

import Foundation

enum TaskListItemPayload: Equatable {
    case general(GeneralTaskShadow)
    case shopping(ShoppingItemShadow)
}

struct TaskListItemShadow: Identifiable, Equatable {
    let payload: TaskListItemPayload
    
    var id: UUID {
        switch payload {
        case .general(let shadow):
            return shadow.id
        case .shopping(let shadow):
            return shadow.id
        }
    }
    
    var isDone: Bool {
        switch payload {
        case .general(let shadow): shadow.isDone
        case .shopping(let shadow): shadow.isDone
        }
    }
    
    var title: String {
        switch payload {
        case .general(let shadow): shadow.text
        case .shopping(let shadow): shadow.name
        }
    }
    
    func fold<R>(
        general: (GeneralTaskShadow) -> R,
        shopping: (ShoppingItemShadow) -> R
    ) -> R {
        switch self.payload {
        case .general(let shadow): return general(shadow)
        case .shopping(let shadow): return shopping(shadow)
        }
    }
    
    func toggled() -> TaskListItemShadow {
        switch payload {
        case .general(let general):
            return TaskListItemShadow(payload: .general(general.toggle()))
        case .shopping(let shopping):
            return TaskListItemShadow(payload: .shopping(shopping))
        }
    }
}
