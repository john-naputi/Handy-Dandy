//
//  ShoppingListHost.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/24/25.
//

import SwiftUI
import SwiftData

struct ShoppingListBridge {
    let context: ModelContext
    
    func fetchOrCreate(for plan: Plan) throws -> ShoppingList {
        if let existing = plan.shoppingList { return existing }
        let shoppingList = ShoppingList(
            title: plan.title,
            plan: plan
        )
        
        context.insert(shoppingList)
        try context.save()
        
        return shoppingList
    }
}

struct ShoppingListHost: View {
    @Environment(\.modelContext) private var modelContext
    let plan: Plan
    
    @State private var store: ShoppingListStore?
    @State private var errorText: String?
    
    var body: some View {
        Group {
            if let store {
                ShoppingListContainer(store: store)
            } else {
                ProgressView("Loading...")
                    .task { await bootstrap() }
            }
        }
        .navigationTitle(plan.title.isEmpty ? "Shopping List" : plan.title)
        .alert("error", isPresented: .constant(errorText != nil)) {
            Button("OK") { errorText = nil }
        } message: { Text(errorText ?? "There was a problem loading your shopping list") }
    }
    
    private func bootstrap() async {
        do {
            let target = plan.planId
            var descriptor = FetchDescriptor<ShoppingList>(
                predicate: #Predicate { $0.id == target }
            )
            descriptor.fetchLimit = 1
            guard let fetchedPlan = try modelContext.fetch(descriptor).first else {
                errorText = "Could not find the selected shopping list"
                return
            }
            
            let repository = ShoppingListBridge(context: modelContext)
            let list = try repository.fetchOrCreate(for: plan)
            store = ShoppingListStore(context: modelContext, listId: list.id)
        } catch {
            errorText = error.localizedDescription
        }
    }
}

#Preview {
    let plan = Plan(title: "Test Plan")
    ShoppingListHost(plan: plan)
}
