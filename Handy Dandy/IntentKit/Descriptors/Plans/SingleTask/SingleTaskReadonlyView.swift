//
//  SingleTaskPlanView.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/21/25.
//

import SwiftUI

struct SingleTaskReadonlyView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var editTaskSheet: Bool = false
    
    let shadow: SingleTaskShadow
    
    var onToggleDone: () -> Void = {}
    var onEditTitle: () -> Void = {}
    var onEditNotes: () -> Void = {}
    var onClearNotes: () -> Void = {}
    var onSetDue: () -> Void = {}
    var onClearDue: () -> Void = {}
    var onEdit: () -> Void = {}
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(shadow.planTitle.isEmpty ? "Untitled Task" : shadow.planTitle)
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    ProgressView(value: shadow.progress)
                        .accessibilityLabel("Task completion progress")
                        .accessibilityValue(shadow.isDone ? "100 percent" : "0 percent")
                    Text(shadow.statusText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .contextMenu {
                    Button {
                        onEditTitle()
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                }
            } header: {
                Text("Summary").textCase(nil)
            }
            
            Section {
                HStack(spacing: 12) {
                    Image(systemName: shadow.isDone ? "checkmark.circle.fill" : "circle")
                        .imageScale(.large)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(shadow.isDone ? .green : .primary)
                        .accessibilityHidden(true)
                    Text("Mark as \(shadow.isDone ? "incomplete" : "complete")")
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture(perform: onToggleDone)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(shadow.planTitle.isEmpty ? "Task" : shadow.planTitle)
                .accessibilityValue(shadow.isDone ? "Completed" : "Not completed")
                .accessibilityHint("Double-tap to toggle completion")
                .accessibilityAddTraits(.isButton)
                .swipeActions {
                    Button {
                        
                    } label: {
                        Label(shadow.isDone ? "Mark Not Done" : "Mark Done",
                              systemImage: shadow.isDone ? "arrow.uturn.left" : "checkmark")
                    }
                }
            } header: {
                Text("Action").textCase(nil)
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    if let notes = shadow.notes, !notes.isEmpty {
                        Text(notes)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityLabel("Notes")
                            .accessibilityValue(notes)
                    } else {
                        Text("No notes")
                            .foregroundStyle(.secondary)
                            .accessibilityLabel("Notes")
                            .accessibilityValue("None")
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture(perform: onEditNotes)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Notes")
                .accessibilityHint("Double-tap to edit notes")
                .accessibilityAddTraits(.isButton)
                .swipeActions(allowsFullSwipe: false) {
                    Button {
                        onEditNotes()
                    } label: {
                        Label("Edit notes", systemImage: "applepencil")
                    }
                    
                    if (shadow.notes?.trimmed().isEmpty == false) {
                        Button() {
                            onClearNotes()
                        } label: {
                            Label("Clear Notes", systemImage: "eraser.fill")
                        }
                    }
                }
            } header: {
                Text("Notes").textCase(nil)
            }
            
            Section {
                HStack {
                    Text("Due At")
                    Spacer()
                    if let dueAt = shadow.dueAt {
                        Text(dueAt.formatted(date: .abbreviated, time: .shortened))
                            .foregroundStyle(.secondary)
                    } else {
                        Text("No Due Date").foregroundStyle(.secondary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture(perform: onSetDue)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Due date")
                .accessibilityValue(
                    shadow.dueAt?.formatted(date: .abbreviated, time: .shortened) ?? "None"
                )
                .accessibilityHint("Double-tap to set or edit the due date")
                .accessibilityAddTraits(.isButton)
                .swipeActions(allowsFullSwipe: false) {
                    Button {
                        onSetDue()
                    } label: {
                        Label("Edit Due Date", systemImage: "applepencil")
                    }
                    
                    if shadow.dueAt != nil {
                        Button {
                            onClearDue()
                        } label: {
                            Label("Clear Due", systemImage: "calendar.badge.minus")
                        }
                    }
                }
            } header: {
                Text("Schedule").textCase(nil)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Task")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.default, value: shadow.isDone)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "square.and.pencil")
                }
            }
        }
    }
}

#Preview {
    Group {
        NavigationStack {
            SingleTaskReadonlyView(
                shadow: .init(
                    title: "Pick up dry cleaning",
                    notes: "Tickets in wallet.",
                    isDone: false,
                    dueAt: .now.addingTimeInterval(3600*24)
                ),
                onToggleDone: {},
                onEditTitle: {},
                onEditNotes: {},
                onSetDue: {},
                onClearDue: {}
            )
        }

        NavigationStack {
            SingleTaskReadonlyView(
                shadow: .init(
                    title: "Email project update",
                    notes: nil,
                    isDone: true,
                    dueAt: nil
                )
            )
        }
    }
}
