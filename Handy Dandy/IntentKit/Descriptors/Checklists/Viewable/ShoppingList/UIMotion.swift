//
//  UIMotion.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/17/25.
//

import UIKit
import SwiftUI

@inline(__always)
func animateRespectingReduceMotion(_ body: @escaping () -> Void, _ animation: Animation = .easeInOut) {
    if UIAccessibility.isReduceMotionEnabled {
        body()
    } else {
        withAnimation(animation) {
            body()
        }
    }
}
