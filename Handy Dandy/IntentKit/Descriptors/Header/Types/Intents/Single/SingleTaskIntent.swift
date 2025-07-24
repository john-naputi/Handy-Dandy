//
//  TaskDescriptorBindings.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/29/25.
//

import SwiftUI

struct SinglePlanTaskIntent : PlanTaskIntent {
    var data: SinglePlanTaskPayload
}

struct SingleChecklistTaskIntent : ChecklistTaskIntent {
    var data: SingleChecklistTaskPayload
}
