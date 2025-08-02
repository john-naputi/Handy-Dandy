//
//  FieldLabel.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/5/25.
//

import SwiftUI

struct FieldLabel: View {
    var title: String
    var isRequired: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            if !isRequired {
                Text("(Optional)")
                    .font(.headline)
            }
        }
    }
}

#Preview {
    let title = "Title"
    
    FieldLabel(title: title, isRequired: true)
}
