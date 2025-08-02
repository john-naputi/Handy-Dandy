//
//  Payload.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/1/25.
//

protocol Payload {
    associatedtype Item
    
    var item: Item { get }
}

struct IntentPayload<TItem> {
    var item: TItem
}
