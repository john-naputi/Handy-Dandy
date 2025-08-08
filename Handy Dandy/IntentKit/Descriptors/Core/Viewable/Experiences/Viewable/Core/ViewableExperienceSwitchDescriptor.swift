//
//  ViewableExperienceSwitchDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/4/25.
//

import SwiftUI

struct ViewableExperienceSwitchDescriptor: View {
    var intent: any ExperienceIntent
    
    var body: some View {
        switch intent {
        case _ as SingleExperienceIntent:
            Text("Single experience")
        case let multiExperience as MultiExperienceIntent:
            ViewableMultiExperienceDescriptor(experiences: multiExperience.data)
        default:
            Text("Invalid experience intent!!!")
        }
    }
}

#Preview {
    let intent = SingleExperienceIntent(data: Experience())
    ViewableExperienceSwitchDescriptor(intent: intent)
}
