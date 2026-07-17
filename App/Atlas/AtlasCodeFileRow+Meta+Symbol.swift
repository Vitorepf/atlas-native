import SwiftUI
import AtlasCore

// File status symbol — peel de AtlasCodeFileRow+Meta.
// Mutate → AtlasCodeFileRow+Meta+Symbol+Mutate.swift

extension AtlasCodeFileRow {
    var symbol: String {
        if let mutate = symbolMutate { return mutate }
        switch file.status {
        case .renamed: return "arrow.right"
        case .copied: return "doc.on.doc"
        case .typeChanged: return "arrow.triangle.2.circlepath"
        case .unknown: return "questionmark"
        default: return "questionmark"
        }
    }
}
