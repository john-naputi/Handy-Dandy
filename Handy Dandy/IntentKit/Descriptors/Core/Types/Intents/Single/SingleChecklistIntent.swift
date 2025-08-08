//
//  ChecklistDescriptorBindings.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/29/25.
//

import SwiftUI

struct SingleChecklistIntent : Intent, ChecklistIntent {
    var data: SingleChecklistPayload
}
