//
//  EditablePlanIntent.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/31/25.
//

struct EditablePlanIntent : EditableIntent, PlanIntent {
    var data: Plan
    var mode: EditMode
}
