//
//  ChecklistPayload.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/30/25.
//

struct ChecklistPayload<T> {
    var plan: Plan
    var checklist: T
}

typealias SingleChecklistPayload = ChecklistPayload<Checklist>
typealias MultiChecklistPayload = ChecklistPayload<[Checklist]>
