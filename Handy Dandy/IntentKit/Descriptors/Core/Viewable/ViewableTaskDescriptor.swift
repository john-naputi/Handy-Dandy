//
//  ReadonlyTaskDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/29/25.
//

import SwiftUI

struct ViewableTaskDescriptor: View {
    var title: String
    var description: String
    
    var body: some View {
        Text(title)
        Text(description)
    }
}
