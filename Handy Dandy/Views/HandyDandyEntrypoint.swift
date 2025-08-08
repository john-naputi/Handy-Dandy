//
//  PlansListView.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/21/25.
//

import SwiftUI
import SwiftData

struct HandyDandyEntrypoint: View {
    @Query var plans: [Plan]
    @Query var experiences: [Experience]
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @State private var showCreateSheet = false
    
    var body: some View {
//        let intent = MultiPlanIntent(data: plans)
//        let payload = DescriptorPayload(header: "Plans", mode: .view(.plan(intent)))
        
        let intent = MultiExperienceIntent(data: experiences)
        let payload = DescriptorPayload(header: "Headers", mode: .view(.experience(intent)))
        DescriptorMediator(payload: payload)
    }
}

#Preview {
    HandyDandyEntrypoint()
}

