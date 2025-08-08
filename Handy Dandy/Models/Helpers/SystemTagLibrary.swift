//
//  SystemTagLibrary.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/5/25.
//

import SwiftUI

struct SystemTag {
    let emoji: String
    let darkColor: Color
    let lightColor: Color
}

let SystemTagLibrary: [String: SystemTag] = [
    "Flow": .init(
        emoji: "🔄",
        darkColor: Color(red: 75/255, green: 0/255, blue: 130/255),
        lightColor: Color(red: 75/255, green: 0/255, blue: 130/255)
    ),
    "Emergency": .init(
        emoji: "🚨",
        darkColor: Color.red.opacity(0.7),
        lightColor: Color.red.opacity(0.9)
    ),
    "Winter": .init(
        emoji: "❄️",
        darkColor: .blue,
        lightColor: Color(red: 70/255, green: 130/255, blue: 180/255)
    ),
    "Spring": .init(
        emoji: "🌷",
        darkColor: .green,
        lightColor: Color(red: 34/255, green: 139/255, blue: 34/255)
    ),
    "Summer": .init(
        emoji: "🌞",
        darkColor: .orange,
        lightColor: Color(red: 204/255, green: 85/255, blue: 0/255)
    ),
    "Autumn": .init(
        emoji: "🍂",
        darkColor: .red,
        lightColor: Color(red: 160/255, green: 82/255, blue: 45/255)
    )
]

extension Color {
    var readableTextColor: Color {
        // Convert SwiftUI Color to UIColor to extract components
        let uiColor = UIColor(self)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Calculate luminance
        let luminance = (0.299 * red + 0.587 * green + 0.114 * blue)

        return luminance > 0.5 ? .black : .white
    }
}
