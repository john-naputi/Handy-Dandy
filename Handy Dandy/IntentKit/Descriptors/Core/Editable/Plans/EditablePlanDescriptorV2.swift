import SwiftUI

fileprivate enum Field { case title, notes }

struct EditablePlanDescriptorV2: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.voAnnouncement) private var voAnnouncement   // <- matches env key above

    @FocusState private var focus: Field?
    private var isAxSize: Bool { typeSize.isAccessibilitySize }

    @State private var draft: DraftPlan
    @State private var titleTouched = false
    @State private var titleHelp: HelpMessage = .none

    private var mode: EditMode
    private let onDone: (Plan, EditMode) -> Void

    private var isValid: Bool {
        !draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(intent: EditablePlanIntent, onDone: @escaping (Plan, EditMode) -> Void) {
        self.mode = intent.mode
        self.onDone = onDone
        _draft = State(wrappedValue: DraftPlan(from: intent.data))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    // Title
                    AdaptiveFormRow(label: "Title", isAxSize: isAxSize, helpMessage: titleHelp) {
                        TextField("Required", text: $draft.title)
                            .textInputAutocapitalization(.words)
                            .submitLabel(.next)
                            .focused($focus, equals: .title)
                            .accessibilityIdentifier("editable.plan.title")
                            .accessibilityHint("Required")
                            .onTapGesture { titleTouched = true }
                            .onSubmit {
                                if !isValid {
                                    titleHelp = .error("Title is required.")
                                    voAnnouncement("Title is required.")
                                    focus = .title
                                } else {
                                    titleHelp = .none
                                    focus = .notes
                                }
                            }
                            .onChange(of: draft.title) { _, newTitle in
                                if titleTouched && !newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    titleHelp = .none
                                }
                            }
                    }
                    .onChange(of: focus) { oldFocus, newFocus in
                        if newFocus != .title && !isValid {
                            titleHelp = .error("Title is required.")
                            voAnnouncement("Title is required.")
                        }
                    }

                    // Description / Notes
                    AdaptiveFormRow(label: "Description", isAxSize: isAxSize, helpMessage: .none, allyLabel: "Description, Optional", forceStacked: true) {
                        TextEditor(text: $draft.notes)
                            .frame(minHeight: isAxSize ? 140 : 96)
                            .scrollContentBackground(.hidden)
                            .background(.clear)
                            .focused($focus, equals: .notes)
                            .accessibilityIdentifier("editable.plan.notes")
                    }
                }

                // Kind
                Section("Kind") {
                    if isAxSize {
                        Picker("Plan Kind", selection: $draft.kind) {
                            ForEach(PlanKind.allCases) { kind in
                                Text(kind.displayName).tag(kind)
                            }
                        }
                        .pickerStyle(.navigationLink)
                        .accessibilityIdentifier("editable.plan.kind.picker")
                    } else {
                        Picker("Plan Kind", selection: $draft.kind) {
                            ForEach(PlanKind.allCases) { kind in
                                Text(kind.displayName).tag(kind)
                            }
                        }
                        .pickerStyle(.segmented)
                        .accessibilityIdentifier("editable.plan.kind.segmented")
                    }
                }

                // Type
                Section("Type") {
                    if isAxSize {
                        Picker("Plan Type", selection: $draft.type) {
                            ForEach(draft.kind.allowedPlanTypes) { type in
                                HStack(spacing: 8) {
                                    Image(systemName: type.symbol).foregroundStyle(type.tintColor)
                                    Text(type.displayName)
                                }
                                .tag(type)
                            }
                        }
                        .pickerStyle(.navigationLink)
                        .accessibilityIdentifier("editable.plan.type.picker")
                    } else {
                        Picker("Plan Type", selection: $draft.type) {
                            ForEach(draft.kind.allowedPlanTypes) { type in
                                HStack(spacing: 8) {
                                    Image(systemName: type.symbol).foregroundStyle(type.tintColor)
                                    Text(type.displayName)
                                }
                                .tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .accessibilityIdentifier("editable.plan.type.picker")
                    }
                }
            }
            .navigationTitle(mode == .create ? "New Plan" : "Edit Plan")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(mode == .create ? "Create" : "Save") {
                        guard isValid else { return }
                        confirm()
                    }
                    .disabled(!isValid)
                    .accessibilityHint(isValid ? "Saves this plan" : "Enter a title to enable Save")
                    .accessibilityIdentifier("editable.plan.save")
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear { focus = .title }
        }
    }

    private func confirm() {
        switch mode {
        case .create:
            let plan = draft.materialize()
            modelContext.insert(plan)
            try? modelContext.save()
            onDone(plan, .create)
            dismiss()
        case .update:
            let plan = draft.boundPlan
            draft.move(to: plan)
            try? modelContext.save()
            onDone(plan, .update)
            dismiss()
        }
    }
}

#Preview {
    let plan = Plan()
    let intent = EditablePlanIntent(data: plan, mode: .create)
    EditablePlanDescriptor(intent: intent)
}
