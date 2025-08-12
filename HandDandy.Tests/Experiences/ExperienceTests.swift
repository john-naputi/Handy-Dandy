//
//  ExperienceTests.swift
//  HandDandy.Tests
//
//  Created by John Naputi on 8/10/25.
//

@testable import Handy_Dandy

import Testing
import Foundation

func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
    let components = DateComponents(year: year, month: month, day: day)
    
    return Calendar(identifier: .gregorian).date(from: components)!
}

@Suite("Experience Tests")
struct ExperienceTests {
    
    @Test("Init sets back references to plans")
    func initSetsPlanBackReferences() {
        let p1 = Plan(title: "First")
        let p2 = Plan(title: "Second")
        let experience = Experience(title: "Weekend", plans: [p1, p2])
        
        #expect(p1.experience == experience)
        #expect(p2.experience == experience)
        #expect(experience.plans.count == 2)
    }
    
    @Test("add() ignores system tags, dedups by name, and sets back-reference")
    func addTag_rulesAndBackrefs() {
        let experience = Experience(title: "Trip")
        let firstTag = ExperienceTag(name: "Packing")
        let userTagDedup = ExperienceTag(name: "Packing")
        let systemTag = ExperienceTag(name: "Flow", isSystem: true)
        
        experience.add(firstTag)
        experience.add(userTagDedup)
        experience.add(systemTag)
        
        #expect(experience.tags.count == 1)
        #expect(experience.tags.first?.name == "Packing")
        #expect(firstTag.experience == experience)
    }
    
    @Test("remove() returns removed tag and updates the list")
    func removeTag_removesAndReturns() {
        let experience = Experience(title: "Weekend")
        let tag1 = ExperienceTag(name: "Food")
        let tag2 = ExperienceTag(name: "Hike")
        experience.add(tag1)
        experience.add(tag2)
        
        let removed = experience.remove(tag1)
        #expect(removed?.id == tag1.id)
        #expect(experience.tags.count == 1)
        #expect(experience.tags.first?.id == tag2.id)
        
        let bogus = ExperienceTag(name: "Ghost", isSystem: false, emoji: "👻")
        #expect(experience.remove(bogus) == nil)
    }
    
    @Test("allTags = systemTag first + user tags sorted by name")
    func allTags_compositionAndOrdering() {
        let experience = Experience(title: "Operations", type: .flow)
        let tag1 = ExperienceTag(name: "Alpha")
        let tag2 = ExperienceTag(name: "Bravo")
        let tag3 = ExperienceTag(name: "Charlie")
        experience.add(tag1); experience.add(tag2); experience.add(tag3)
        
        let allTags = experience.allTags
        #expect(allTags.count == 1 + experience.tags.count)
        
        #expect(allTags.first?.isSystem == true)
        #expect(allTags.first?.name == ExperienceType.flow.displayName)
        #expect(allTags.first?.emoji == experience.type.emoji)
        
        let names = allTags.dropFirst().map { $0.name }
        #expect(names == ["Alpha", "Bravo", "Charlie"])
    }
    
    @Test("Init applies tag rules: ignore system and dups, sets back-refs")
    func initWithTags_respectsAddRules() {
        let tag1 = ExperienceTag(name: "Alpha")
        let tag1Dup = ExperienceTag(name: "Alpha")
        let systemTag = ExperienceTag(name: "Flow")
        
        let experience = Experience(title: "Race Day")
        experience.add(tag1); experience.add(tag1Dup); experience.add(systemTag)
        print("Ready")
        
        #expect(experience.tags.count == 1)
        #expect(experience.tags.first?.name == "Alpha")
        #expect(tag1.experience == experience)
    }
    
    // MARK: - Dates
    
    @Test("getExperienceDate returns single date when start==end")
    func getExperienceDate_sameDay() {
        let date = makeDate(2025, 8, 11)
        let experience = Experience(title: "Ski Day", startDate: date, endDate: date)
        
        let experienceDate = experience.getExperienceDate()
        #expect(!experienceDate.isEmpty)
        #expect(!experienceDate.contains(" - "))
    }
    
    @Test("getExperienceDate returns range when start != end")
    func getExperienceDate_range() {
        let start = makeDate(2025, 8, 11)
        let end = makeDate(2025, 8, 12)
        let experience = Experience(title: "Ski Day", startDate: start, endDate: end)
        
        let experienceDate = experience.getExperienceDate()
        #expect(experienceDate.contains(" - "))
        #expect(!experienceDate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    // MARK: - System tag mirrors type
    
    @Test("systemTag mirrors type displayName and Emoji")
    func systemTag_matchesType() {
        let flow = Experience(title: "Flowy", type: .flow)
        #expect(flow.systemTag.isSystem)
        #expect(flow.systemTag.name == ExperienceType.flow.displayName)
        #expect(flow.systemTag.displayEmoji == ExperienceType.flow.emoji)
        
        let emergency = Experience(title: "Emergency", type: .emergency)
        #expect(emergency.systemTag.isSystem == true)
        #expect(emergency.systemTag.name == ExperienceType.emergency.displayName)
        #expect(emergency.systemTag.emoji == ExperienceType.emergency.emoji)
    }
    
    // MARK: - Init semantics and defaults
    @Test("Init preserves provided id and assigns defaults")
    func init_preservesIdAndDefaults() {
        let id = UUID()
        let experience = Experience(id: id, title: "Skiing")
        #expect(experience.id == id)
        #expect(experience.type == .flow)
        #expect(experience.isRecurring == false)
        #expect(experience.recurrenceRule == nil)
        #expect(experience.budgetLimit == nil)
        #expect(experience.pinned == false)
        #expect(experience.colorTag == nil)
        #expect(experience.plans.isEmpty)
        #expect(experience.tags.isEmpty)
    }
}
