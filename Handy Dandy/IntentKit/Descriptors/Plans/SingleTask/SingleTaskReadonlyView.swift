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
                
                Button {
                    onEditNotes()
                } label: {
                    Label("Edit Notes", systemImage: "square.and.pencil")
                }
                .accessibilityHint("Open the notes editor")
            } header: {
                Text("Notes").textCase(nil)
            }
            
            Section {
                if let dueAt = shadow.dueAt {
                    HStack {
                        Text("Due At")
                        Spacer()
                        Text(dueAt.formatted(date: .abbreviated, time: .shortened))
                            .foregroundStyle(.secondary)
                            .accessibilityLabel("Due At")
                            .accessibilityValue(dueAt.formatted(date: .abbreviated, time: .shortened))
                    }
                    Button(role: .destructive) {
                        onClearDue()
                    } label: {
                        Label("Clear Due Date", systemImage: "calendar.badge.minus")
                    }
                } else {
                    Text("No due date").foregroundStyle(.secondary)
                    Button(role: .destructive) {
                        onSetDue()
                    } label: {
                        Label("Set Due Date", systemImage: "calendar.badge.plus")
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
