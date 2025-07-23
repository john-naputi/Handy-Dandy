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
                            HStack(spacing: 8) {
                                Text(plan.title)
                                    .font(.headline)
                                Text(plan.planDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline)
                            }
                            
                            if let description = plan.planDescription {
                                Text(description)
                                    .font(.body)
                                    .lineLimit(2)
                                    .padding(.top, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Plans")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreatePlanView()
                    .environment(\.modelContext, modelContext)
            }
        }
        .onAppear {
            for plan in plans {
                print("Plan title: \(plan.title)', created at \(plan.planDate)")
            }
        }
    }
}

#Preview {
    PlansListView()
}

