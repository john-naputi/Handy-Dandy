//
//  EditableTaskListDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/18/25.
//

import SwiftUI
import Combine

struct EditableTaskListDescriptor: View {
    enum Field: Hashable {
        case title, newItem, item(UUID)
    }
    
    private let longListThreshold = 6
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State var draft: DraftTaskList
    var onCancel: () -> Void
    var onSave: (DraftTaskList) -> Void
    
    @State private var newText: String = ""
    @FocusState private var focusedField: Field?
    @State private var isKeyboardVisible: Bool = false
    @State private var cancelBag: Set<AnyCancellable> = []
    
    private var useBottomBar: Bool {
        if focusedField == .newItem { return false }
        return isKeyboardVisible || draft.items.count >= longListThreshold
    }
    
    init(initial: DraftTaskList,
         onCancel: @escaping () -> Void,
         onSave: @escaping (DraftTaskList) -> Void) {
        _draft = State(initialValue: initial)
        self.onCancel = onCancel
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: Title
                Section("Title") {
                    TextField("Task List Title", text: $draft.title)
                        .textInputAutocapitalization(.words)
                        .focused($focusedField, equals: .title)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .newItem
                        }
                }
                
                // MARK: Items
                Section(header: itemsHeader()) {
                    ForEach($draft.items) { $item in
                        HStack(spacing: 12) {
                            Button {
                                item.isDone.toggle()
                                #if os(iOS)
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                #endif
                            } label: {
                                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                    .imageScale(.large)
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(item.isDone ? Color(UIColor.systemGreen) : .primary)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(item.isDone ? "Mark as not done" : "Mark as done")
                            .accessibilityHint("toggles completion for \(item.text.isEmpty ? "this task" : item.text)")
                            
                            TextField("Task", text: $item.text)
                                .focused($focusedField, equals: .item(item.id))
                                .submitLabel(.next)
                                .onSubmit { focusedField = .newItem }
                                .strikethrough(item.isDone)
                                .foregroundStyle(item.isDone ? .secondary : .primary)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .id(item.id)
                        .accessibilityAction(named: item.isDone ? "Mark as not done" : "Mark as done") {
                            item.isDone.toggle()
                        }
                        .accessibilityAction(named: "Delete task") {
                            removeItems(where: { $0.id == item.id })
                        }
                        .accessibilityAction(named: "Edit text") {
                            focusedField = .item(item.id)
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(item.text.isEmpty ? "The task is empty" : item.text)
                        .accessibilityValue(item.isDone ? "The task is complete" : "The task is not complete")
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                removeItems(where: { $0.id == item.id })
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete { offsets in
                        draft.items.remove(atOffsets: offsets)
                    }
                    .onMove { source, destination in
                        draft.items.move(fromOffsets: source, toOffset: destination)
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                        TextField("Add Task...", text: $newText)
                            .focused($focusedField, equals: .newItem)
                            .submitLabel(.done)
                            .onSubmit{ addNew() }
                        Button("Add") { addNew() }
                            .disabled(newText.trimmed().isEmpty)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedField = .newItem
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .animation(.default, value: draft.items)
            .navigationTitle("Edit List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .bold()
                        .disabled(!canSave)
                }
            }
        }
        .onAppear {
            focusedField = draft.title.trimmed().isEmpty ? .title : .newItem
            observeKeyboard()
        }
        .onDisappear {
            unobserveKeyboard()
        }
    }
    
    private func itemsHeader() -> some View {
        let total = max(draft.items.count, 1)
        let done = draft.items.filter(\.isDone).count
        let remaining = total - done
        let progress = Double(done) / Double(total)
        
        return VStack(alignment: .leading, spacing: 4) {
            Text("Tasks")
                .accessibilityAddTraits(.isHeader)
            
            ProgressView(value: progress)
                .accessibilityLabel("Progress")
                .accessibilityValue("\(done) of \(total) tasks complete")
            
            Text(getProgressViewText(count: remaining))
                .font(.footnote.weight(.semibold))
        }
        .animation(.snappy, value: done)
    }
    
    private func getProgressViewText(count: Int) -> String {
        if count > 1 {
            return "\(count) Tasks Remaining"
        } else if count == 1 {
            return "1 Task Remaining"
        } else {
            return "All Tasks Completed!"
        }
    }
    
    // MARK: Actions
    private var canSave: Bool {
        !draft.title.trimmed().isEmpty || draft.items.contains { !$0.text.trimmed().isEmpty }
    }
    
    private func addNew() {
        let text = newText.trimmed()
        guard !text.isEmpty else { return }
        draft.items.append(DraftTaskItem(id: UUID(), text: text, isDone: false))
        newText = ""
        focusedField = .newItem
        
        UIAccessibility.post(notification: .announcement, argument: "Task added")
    }
    
    private func removeItems(where predicate: (DraftTaskItem) -> Bool) {
        draft.items.removeAll(where: predicate)
    }
    
    private func save() {
        draft.title = draft.title.trimmed()
        draft.items = draft.items
            .map { DraftTaskItem(id: $0.id, text: $0.text.trimmed(), isDone: $0.isDone )}
            .filter { !$0.text.isEmpty }
        onSave(draft)
    }
    
    // MARK: Utilities
    private func observeKeyboard() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { _ in isKeyboardVisible = true }
            .store(in: &cancelBag)
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { _ in
                isKeyboardVisible = false
            }
            .store(in: &cancelBag)
    }
    
    private func unobserveKeyboard() {
        cancelBag.removeAll()
    }
}

#Preview {
    let draft = DraftTaskList(
        id: UUID(),
        title: "REI Run",
        items: [
            .init(id: UUID(), text: "Buy gels", isDone: false),
            .init(id: UUID(), text: "Charge Watch", isDone: true),
            .init(id: UUID(), text: "Lay Out Kit", isDone: false)
        ]
    )
    EditableTaskListDescriptor(initial: draft, onCancel: {}, onSave: { _ in })
}
