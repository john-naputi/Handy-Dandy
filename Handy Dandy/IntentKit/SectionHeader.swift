//
//  SectionHeader.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/28/25.
//

import SwiftUI

struct SectionHeader<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        Section {
            content()
        } header: {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    SectionHeader(title: "Hello") {
        Text("Woah!!!")
    }
}
