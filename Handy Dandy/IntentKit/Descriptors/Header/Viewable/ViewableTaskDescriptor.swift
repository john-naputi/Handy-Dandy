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

// TODO: FIX THIS
//#Preview {
//    let task = Task(title: "Task", description: "Description")
//    let bindings = SingleTaskIntent(
//    ReadonlyTaskDescriptor(title: bindings.model.title, description: bindings.model.taskDescription)
//}
//
//fileprivate struct ReadonlyTaskDescriptorPreview: View {
//    var bindings: SingleTaskIntent
//    
//    var body: some View {
//        ReadonlyTaskDescriptor(title: bindings.model.title, description: bindings.model.taskDescription)
//    }
//}
