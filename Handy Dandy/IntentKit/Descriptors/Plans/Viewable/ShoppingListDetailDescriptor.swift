//
//  ShoppingListDetailDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/14/25.
//

import SwiftUI

struct ShoppingListDetailDescriptor: View {
    let checklist: Checklist
    
    var body: some View {
        Text("Shopping List Detail")
        Text(checklist.title)
    }
}

#Preview {
    let checklist = Checklist(title: "First Shopping List", kind: .shoppingList)
    ShoppingListDetailDescriptor(checklist: checklist)
}
