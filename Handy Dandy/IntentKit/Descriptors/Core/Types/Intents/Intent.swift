//
//  BaseDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/29/25.
//

import Foundation
import SwiftUI

enum DescriptorMode {
    case view, edit
}

protocol Intent {
    associatedtype TData
    var data: TData { get }
}
