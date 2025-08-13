//
//  EmptyPlansListDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/8/25.
//

import SwiftUI

struct EmptyPlansListDescriptor: View {
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
    let message = "There are no plans for this experience."
    EmptyPlansListDescriptor(message: message)
}
