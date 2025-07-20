//
//  Item.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/20/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
