//
//  SingleChecklistHeader.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/31/25.
//

import SwiftUI

struct SingleChecklistHeader: View {
    var checklist: Checklist
    
    var body: some View {
        SectionHeader(title: "Name") {
            HStack {
                Text(checklist.title)
                if checklist.isComplete {
                    Spacer()
                    Text("Completed")
                        .font(.caption)
                        .padding(6)
                        .background(Color(uiColor: .systemGreen))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding(.trailing)
                        .transition(
                            .opacity.combined(with: .move(edge: .trailing))
                        )
                        .animation(.easeOut, value: checklist.isComplete)
                }
            }
        }
    }
}

#Preview {
    let checklist = Checklist(title: "Costco", checklistDescription: "Monthly groceries")
    SingleChecklistHeader(checklist: checklist)
}
