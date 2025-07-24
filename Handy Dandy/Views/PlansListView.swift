//
//  PlansListView.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/21/25.
//

import SwiftUI
import SwiftData

struct PlansListView: View {
    @Query var plans: [Plan]
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @State private var showCreateSheet = false
    
    var body: some View {
        let intent = MultiPlanIntent(data: plans)
        let payload = DescriptorPayload(header: "Plans", mode: .view(.plan(intent)))
        DescriptorMediator(payload: payload)
    }
}

#Preview {
    PlansListView()
}

