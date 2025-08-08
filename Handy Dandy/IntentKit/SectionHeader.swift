//
//  SectionHeader.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/28/25.
//

import SwiftUI

struct SectionHeader<Content: View>: View {
    let title: String
    let isRequired: Bool
    
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        Section {
            content()
        } header: {
            FieldLabel(title: title, isRequired: isRequired)
        }
    }
}

#Preview {
    SectionHeader(title: "Hello", isRequired: false) {
        Text("Woah!!!")
    }
}
