//
//  DraftExperience.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/6/25.
//

import Foundation

@Observable
class DraftExperience {
    var title: String = ""
    var description: String? = nil
    var type: ExperienceType = .flow
    var startDate: Date = .now
    var endDate: Date = .now
    var tags: [DraftTag] = []
    
    private var originalTags: [DraftTag] = []
    
    init() {}
    
    init(from experience: Experience) {
        self.title = experience.title
        self.description = experience.experienceDescription
        self.type = experience.type
        self.startDate = experience.startDate
        self.endDate = experience.endDate
        self.tags = experience.tags.map { DraftTag(name: $0.name, emoji: $0.emoji, isSystem: $0.isSystem) }
        
        self.originalTags = self.tags
    }
    
    func to(experience: Experience? = nil) -> Experience {
        let model = experience ?? Experience()
        model.title = self.title
        model.experienceDescription = self.description
        model.type = self.type
        model.startDate = self.startDate
        model.endDate = self.endDate
        
        return model
    }
    
    func tagsToAdd(comparedTo existing: [ExperienceTag]) -> [ExperienceTag] {
        let existingKeys = Set(existing.map { $0.name.normalizedName })
        
        return self.tags.filter { draft in
            !existingKeys.contains(draft.normalizedKey)
        }
        .map { draft in
            ExperienceTag(name: draft.name, isSystem: draft.isSystem, emoji: draft.emoji)
        }
    }
    
    func tagsToDelete(from experience: Experience) -> [ExperienceTag] {
        let originalKeys = Set(self.originalTags.map { $0.normalizedKey })
        let updatedKeys = Set(self.tags.map { $0.normalizedKey })
        
        let removedKeys = originalKeys.subtracting(updatedKeys)
        
        return experience.tags.filter { tag in
            removedKeys.contains(tag.name.normalizedName)
        }
    }
    
    func addDraftTag(_ tag: DraftTag) {
        guard self.tags.firstIndex(where: { $0.normalizedKey == tag.normalizedKey }) != nil else {
            self.tags.append(tag)
            
            return
        }
        
        return
    }
}
