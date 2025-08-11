//
//  ExperienceTests.swift
//  HandDandy.Tests
//
//  Created by John Naputi on 8/10/25.
//

@testable import Handy_Dandy
import Testing

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
    
    @Test("Init adds tags properly")
    func initAddsTagsProperly() {
        
    }
}
