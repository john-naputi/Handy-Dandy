//
//  TagDiffResult.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/6/25.
//

import Foundation

struct TagDiffResult {
    let toAdd: [DraftTag]
    let toRemove: [ExperienceTag]
}

func diffTags(
    original: [ExperienceTag],
    draft: [DraftTag]
) -> TagDiffResult {
    let originalMap = Dictionary(uniqueKeysWithValues: original.map { ( $0.normalizedKey, $0) })
    let draftMap = Dictionary(uniqueKeysWithValues: draft.map { ( $0.normalizedKey, $0) })
    
    let originalKeys = Set(originalMap.keys)
    let draftKeys = Set(draftMap.keys)
    
    let addKeys = draftKeys.subtracting(originalKeys)
    let removeKeys = originalKeys.subtracting(draftKeys)
    
    let toAdd = addKeys.compactMap { draftMap[$0] }
    let toRemove = removeKeys.compactMap { originalMap[$0] }
    
    return TagDiffResult(toAdd: toAdd, toRemove: toRemove)
}
