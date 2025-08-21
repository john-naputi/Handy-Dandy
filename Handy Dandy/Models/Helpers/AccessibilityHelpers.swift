//
//  AccessibilityHelpers.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/20/25.
//

import UIKit

struct AccessibilityHelpers {
    static func announce(_ text: String) {
        UIAccessibility.post(notification: .announcement, argument: text)
    }
}
