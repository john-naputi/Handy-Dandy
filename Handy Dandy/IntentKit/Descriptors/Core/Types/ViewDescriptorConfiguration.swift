//
//  DescriptorViewConfiguration.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/29/25.
//

import SwiftUI

struct ViewDescriptorConfiguration {
    @Binding var triggerEdit: Bool
    var onEdit: (() -> Void)? = nil
}
