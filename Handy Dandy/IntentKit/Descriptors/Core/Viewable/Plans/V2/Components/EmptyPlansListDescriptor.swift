//
//  EmptyPlansListDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/8/25.
//

import SwiftUI

struct EmptyPlansListDescriptor: View {
    var title: String
    var message: String
    
    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
    }
}

#Preview {
    let title = "Plans"
    let message = "There are no plans for this experience."
    EmptyPlansListDescriptor(title: title, message: message)
}
