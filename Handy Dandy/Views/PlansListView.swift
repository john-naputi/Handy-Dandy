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
    @Environment(\.modelContext) private var modelContext
    @State private var showCreateSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(plans) { plan in
                    NavigationLink(destination: PlanDetailView(plan: plan)) {
                        VStack(alignment: .leading) {
                            Text(plan.title)
                                .font(.headline)
                            Text(plan.createdAt.formatted())
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Plans")
            .toolbar {
                Button {
                    showCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreatePlanView()
                    .environment(\.modelContext, modelContext)
            }
        }
        .onAppear {
            for plan in plans {
                print("Plan title: \(plan.title)', created at \(plan.createdAt)")
            }
        }
    }
}

#Preview {
    PlansListView()
}
