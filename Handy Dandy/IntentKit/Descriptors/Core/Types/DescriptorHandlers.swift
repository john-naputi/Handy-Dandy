//
//  DescriptorHandlers.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/29/25.
//

struct DescriptorHandlers<TDescriptorData> {
    var view: ViewDescriptorConfiguration?
    var edit: EditDescriptorConfiguration<TDescriptorData>?
}
