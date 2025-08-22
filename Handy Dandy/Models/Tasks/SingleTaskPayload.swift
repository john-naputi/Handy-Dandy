//
//  SingleTaskPayload.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/21/25.
//

import Foundation

struct GeneralTaskPayload: Codable, Equatable {
    var text: String
    var notes: String?
}

enum SingleTaskPayload: Codable, Equatable {
    case general(GeneralTaskPayload)
    
    var flavor: SingleTaskFlavor {
        switch self {
        case .general: return .general
        }
    }
    
    func fold<R>(general: (GeneralTaskPayload) -> R) -> R {
        switch self {
        case .general(let payload): return general(payload)
            // case .maintenance(let payload): return maintenance(payload)
        }
    }
}
