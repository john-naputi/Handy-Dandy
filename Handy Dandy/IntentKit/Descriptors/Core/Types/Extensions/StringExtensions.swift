//
//  StringExtensions.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/5/25.
//

extension String {
    var normalizedName: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
