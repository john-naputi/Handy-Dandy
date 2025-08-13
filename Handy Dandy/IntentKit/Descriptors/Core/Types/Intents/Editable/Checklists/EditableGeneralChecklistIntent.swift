//
//  EditableChecklistIntent.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/31/25.
//

struct EditableGeneralChecklistIntent : EditableChecklistIntent, ChecklistIntent {
    var data: SingleChecklistPayload
    var mode: EditMode
}
