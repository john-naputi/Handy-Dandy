//
//  EditableExperienceTagSection.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/5/25.
//

import SwiftUI
import SwiftData
import Foundation

fileprivate enum DraftTagMode: Equatable {
    case creating
    case updating(Int)
}

struct EditableExperienceTagSection: View {
    @Environment(\.modelContext) private var modelContext
    @FocusState private var isEmojiFocused: Bool
    
    @Bindable var draft: DraftExperience
    @State private var isModifying: Bool = false
    @State private var tagName: String = ""
    @State private var emoji: String = ""
    @State private var draftTagMode: DraftTagMode? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(Array(draft.tags.enumerated()), id: \.offset) { index, tag in
                        Label {
                            HStack {
                                Button {
                                    self.tagName = tag.name
                                    self.emoji = tag.emoji ?? "🏷️"
                                    draftTagMode = .updating(index)
                                } label: {
                                    Text(tag.name)
                                }
                                Button {
                                    guard let index = draft.tags.firstIndex(of: tag) else { return }
                                    draft.tags.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.white)
                                }
                            }
                        } icon: {
                            Text(tag.emoji ?? "🏷️")
                        }
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(16)
                    }
                    
                    Button(action: {
                        withAnimation {
                            isModifying.toggle()
                            draftTagMode = .creating
                        }
                    }) {
                        Label("Add Tag", systemImage: "plus")
                            .padding(8)
                            .background(Color.accentColor.opacity(0.2))
                            .cornerRadius(16)
                    }
                }
            }
            
            if let mode = draftTagMode {
                HStack {
                    EmojiPickerButton(emoji: $emoji)
                    
                    TextField(mode == .creating ? "Tag Name" : "Edit Tag Name", text: $tagName)
                        .onChange(of: tagName, { oldValue, newValue in
                            if newValue.count > 15 {
                                tagName = String(newValue.prefix(15))
                            }
                        })
                        .focused($isEmojiFocused)
                    
                    Button(mode == .creating ? "Add" : "Update") {
                        submitTag(for: mode)
                    }
                    .disabled(tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func submitTag(for mode: DraftTagMode) {
        switch mode {
        case .creating:
            addTag()
        case .updating(let index):
            draft.tags[index].name = tagName
            draft.tags[index].emoji = emoji
        }
        
        tagName = ""
        emoji = ""
        draftTagMode = nil
    }
    
    private func addTag() {
        let draftTag = DraftTag(name: tagName.trimmingCharacters(in: .whitespacesAndNewlines), emoji: emoji)
        draft.addDraftTag(draftTag)
    }
}

#Preview {
    let draftExperience = DraftExperience()
    EditableExperienceTagSection(draft: draftExperience)
}

fileprivate struct EditableExperienceTagSectionPreview: View {
    @State var draft: DraftExperience
    
    var body: some View {
        EditableExperienceTagSection(draft: draft)
    }
}
