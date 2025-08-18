//
//  FilterBar.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/15/25.
//

import SwiftUI

struct FilterBar: View {
    let filter: Binding<ItemFilter>
    
    var body: some View {
        Picker("", selection: filter) {
            ForEach(ItemFilter.allCases, id: \.self) { itemfilter in
                Text(itemfilter.title).tag(itemfilter)
            }
        }
        .pickerStyle(.segmented)
        .padding(.vertical, 4)
        .accessibilityLabel("Filter Items")
    }
}

#Preview {
    FilterBarPreview()
}

fileprivate struct FilterBarPreview: View {
    @State private var filter: ItemFilter = .all
    
    var body: some View {
        FilterBar(filter: $filter)
    }
}
