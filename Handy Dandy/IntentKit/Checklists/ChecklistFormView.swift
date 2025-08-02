//
//  ChecklistFormView.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/24/25.
//

import SwiftUI
import Foundation

enum ChecklistFormMode : Identifiable {
    case create, edit, view
    
    var id: String {
        switch self {
        case .create: return "create"
        case .edit: return "edit"
        case .view: return "view"
        }
    }
    
    var isEditable: Bool {
        self == .create || self == .edit
    }
    
    var submitButtonLabel: String {
        switch self {
        case .create:
            return "Add"
        case .edit:
            return "Update"
        case .view:
            return ""
        }
    }
}

struct ChecklistFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var checklist: Checklist
    @Binding var mode: ChecklistFormMode
    @State var showAddTask: Bool = false
    @State var taskToEdit: Task? = nil
    
    var onEditPressed: (() -> Void)? = nil
    var submitButtonLabel: String = "Save"
    
    var body: some View {
        NavigationStack {
            Form {
                titleSection()
                descriptionSection()
                TaskListView(
                    tasks: checklist.sortedTasks,
                    showCreateTaskSheet: $showAddTask,
                    onEditTask: { task in
                        taskToEdit = task
                    },
                    onDeleteTask: { indexSet in
                        for index in indexSet {
                            let task = checklist.tasks[index]
                            checklist.tasks.remove(at: index)
                            modelContext.delete(task)
                            try? modelContext.save()
                        }
                    },
                    onTaskCompleted: {
                        if isComplete() {
                            checklist.isComplete = true
                        } else {
                            checklist.isComplete = false
                        }
                        try? modelContext.save()
                    }
                )
            }
            .navigationTitle(getNavigationTitleText())
            .navigationBarBackButtonHidden(mode.isEditable)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    trailingToolbarItem()
                }
                
                if mode.isEditable {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            if mode == .create {
                                dismiss()
                            } else {
                                mode = .view
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddTask) {
            CreateTaskSheet { newTask in
                checklist.tasks.append(newTask)
            }
        }
        .sheet(item: $taskToEdit) { task in
            TaskFormSheet(task: task)
        }
    }
    
    private func isComplete() -> Bool {
        return checklist.tasks.filter({ !$0.isComplete }).isEmpty
    }
    
    @ViewBuilder
    func sectionTitle(_ title: String) -> some View {
        Text(title).foregroundColor(Color.primary.opacity(0.6))
    }
    
    @ViewBuilder
    func titleSection() -> some View {
        if mode.isEditable {
            LimitedTextFieldSection(header: "Name", placeholder: "Checklist name", text: $checklist.title)
        } else {
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
    
    @ViewBuilder
    func descriptionSection() -> some View {
        if mode.isEditable {
            LimitedTextEditorInput(sectionHeader: "Description", inputText: $checklist.checklistDescription)
        } else if !checklist.checklistDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            SectionHeader(title: "Description") {
                Text(checklist.checklistDescription)
            }
        }
    }
    
    @ViewBuilder
    func trailingToolbarItem() -> some View {
        if mode.isEditable {
            Button(getEditConfirmationButtonText()) {
                if mode == .create {
                    modelContext.insert(checklist)
                    checklist.plan?.checklists.append(checklist)
                }
                
                try? modelContext.save()
                
                dismiss()
            }
            .disabled(checklist.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        } else {
            Button("Edit") {
                onEditPressed?()
            }
            .buttonStyle(.borderedProminent)
            .disabled(checklist.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
    
    func getNavigationTitleText() -> String {
        switch mode {
        case .view: return "Details"
        case .edit: return "Edit"
        case .create: return "Create"
        }
    }
    
    func getEditConfirmationButtonText() -> String {
        switch mode {
        case .create: return "Submit"
        case .edit: return "Save"
        case .view: return ""
        }
    }
}

//#Preview {
//    ChecklistFormViewPreview()
//}
//
//fileprivate struct ChecklistFormViewPreview: View {
//    @Bindable var checklist: Checklist = Checklist(title: "Sample", checklistDescription: "Sample")
//    @State var mode = ChecklistFormMode.view
//    
//    var body: some View {
//        ChecklistFormView(checklist: $checklist, mode: $mode, submitButtonLabel: "Submit")
//    }
//}
