//
//  ReadonlyChecklistDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/29/25.
//

import SwiftUI
import SwiftData

struct ViewableChecklistDescriptor: View {
    @Environment(\.modelContext) private var modelContext
    
    var payload: SingleChecklistPayload
    @State var showEditChecklistSheet: Bool = false
    
    var body: some View {
        let checklist = payload.checklist
        NavigationStack {
            VStack {
                Form {
                    SectionHeader(title: "Name", isRequired: true) {
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
                    
                    SectionHeader(title: "Description", isRequired: false) {
                        Text(checklist.checklistDescription)
                    }
                }
                
                TaskContainerDelegateDescriptor(container: payload.checklist)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        showEditChecklistSheet.toggle()
                    }
                }
            }
            .sheet(isPresented: $showEditChecklistSheet) {
                let payload = SingleChecklistPayload(plan: payload.plan, checklist: payload.checklist)
                let intent = EditableChecklistIntent(data: payload, mode: .update)
                EditableChecklistDescriptor(intent: intent)
            }
        }
    }
}

#Preview {
    let plan = Plan(title: "Test", description: "Plan", planDate: .now)
    let checklist = Checklist(title: "Checklist", checklistDescription: "Description", plan: plan)
    let payload = SingleChecklistPayload(plan: plan, checklist: checklist)
    let intent = SingleChecklistIntent(data: payload)
    ReadonlyChecklistDescriptorPreview(intent: intent)
}

fileprivate struct ReadonlyChecklistDescriptorPreview: View {
    @State var intent: SingleChecklistIntent
    
    var body: some View {
        ViewableChecklistDescriptor(payload: intent.data)
    }
}
