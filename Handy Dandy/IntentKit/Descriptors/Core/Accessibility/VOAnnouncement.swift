//
//  VOAnnouncement.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/10/25.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

typealias VOAnnouncement = (String) -> Void

private struct VOAnnounceKey: EnvironmentKey {
    static let defaultValue: VOAnnouncement = { message in
        #if canImport(UIKit)
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
        #endif
    }
}

extension EnvironmentValues {
    var voAnnouncement: VOAnnouncement {
        get {
            self[VOAnnounceKey.self]
        } set {
            self[VOAnnounceKey.self] = newValue
        }
    }
}
