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
        ViewableMultiExperienceDescriptor(experiences: experiences)
    }
}

#Preview {
    HandyDandyEntrypoint()
}

