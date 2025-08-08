//
//  EditableIntent.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/31/25.
//

enum EditMode {
    case create, update
}

protocol EditableIntent : Intent {
    var mode: EditMode { get }
}
