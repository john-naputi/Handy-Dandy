//
//  TaskListDescriptorBindings.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/30/25.
//

import SwiftUI

struct MultiPlanTaskIntent : PlanTaskIntent {
    var data: MultiPlanTaskPayload
}

struct MultiChecklistTaskIntent : ChecklistIntent {
    var data: MultiChecklistTaskPayload
}
