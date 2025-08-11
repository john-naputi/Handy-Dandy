//
//  StringExtensions.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/15/25.
//

extension String {
    var normalizedName: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
    
    func trimmed() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension Optional where Wrapped == String {
    var trimmedNonEmpty: String? {
        guard let word = self?.trimmed(), !word.isEmpty else {
            return nil
        }
        
        return word
    }
}
