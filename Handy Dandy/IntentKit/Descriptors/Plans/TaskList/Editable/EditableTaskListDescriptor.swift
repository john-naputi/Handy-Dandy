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
                        .accessibilityLabel("List Title")
                        .accessibilityHint("Enter a name for this list")
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
                                AccessibilityHelpers.announce(item.isDone ? "Marked done" : "Marked not done")
                            } label: {
                                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                    .imageScale(.large)
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(item.isDone ? Color(UIColor.systemGreen) : .primary)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(item.isDone ? "Mark task as not done" : "Mark task as done")
                            .accessibilityHint(item.text.isEmpty ? "Toggles completion" : "Toggles completion for \(item.text)")
                            
                            TextField("Task", text: $item.text)
                                .focused($focusedField, equals: .item(item.id))
                                .submitLabel(.next)
                                .onSubmit { focusedField = .newItem }
                                .strikethrough(item.isDone)
                                .foregroundStyle(item.isDone ? .secondary : .primary)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityLabel("Task")
                                .accessibilityValue(item.isDone ? "Completed" : "Not Completed")
                                .accessibilityHint("Edit the task text")
                                .accessibilityAction(named: item.isDone ? "Mark as not done" : "Mark as done") {
                                    item.isDone.toggle()
                                    AccessibilityHelpers.announce(item.isDone ? "Marked done" : "Marked not done")
                                }
                                .accessibilityAction(named: "Delete task") {
                                    removeItems(where: { $0.id == item.id })
                                    AccessibilityHelpers.announce("Task deleted")
                                }
                                .accessibilityAction(named: "Edit text") {
                                    focusedField = .item(item.id)
                                }
                                .accessibilityAdjustableAction { direction in
                                    switch direction {
                                    case .increment:
                                        moveItems(item.id, delta: 1)
                                        AccessibilityHelpers.announce("Moved down")
                                    case .decrement:
                                        moveItems(item.id, delta: -1)
                                        AccessibilityHelpers.announce("Moved up")
                                    @unknown default:
                                        break
                                    }
                                }
                        }
                        .id(item.id)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                removeItems(where: { $0.id == item.id })
                                AccessibilityHelpers.announce("Task deleted")
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
                            .accessibilityLabel("New task")
                            .accessibilityHint("Enter text for a new task")
                        Button("Add") { addNew() }
                            .disabled(newText.trimmed().isEmpty)
                            .accessibilityHint("Adds the new task to the list")
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
                        .accessibilityLabel("Cancel editing")
                        .accessibilityHint("Discard changes")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .bold()
                        .disabled(!canSave)
                        .accessibilityLabel("Save changes")
                        .accessibilityHint("Save your changes to the list")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .accessibilityLabel("Reorder tasks")
                        .accessibilityHint("Enter reordering mode to move tasks")
                }
            }
        }
        .onAppear {
            focusedField = draft.title.trimmed().isEmpty ? .title : .newItem
            observeKeyboard()
            AccessibilityHelpers.announce("Editing list")
        }
        .onDisappear {
            unobserveKeyboard()
            AccessibilityHelpers.announce("List saved")
        }
    }
    
    private func moveItems(_ id: UUID, delta: Int) {
        guard let index = draft.items.firstIndex(where: { $0.id == id }) else { return }
        let newIndex = max(0, min(draft.items.count - 1, index + delta))
        guard newIndex != index else { return }
        draft.items.move(fromOffsets: IndexSet(integer: index), toOffset: newIndex > index ? newIndex + 1 : newIndex)
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
                .accessibilityLabel("Task completion progress")
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
