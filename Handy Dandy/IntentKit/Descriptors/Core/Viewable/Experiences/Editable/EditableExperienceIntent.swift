//
//  EditableExperienceIntent.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/5/25.
//

struct EditableExperienceIntent: EditableIntent, ExperienceIntent {
    var data: Experience
    var mode: EditMode
    var onCancel: (() -> Void)?
    var onSave: ((Experience) -> Void)?
}
