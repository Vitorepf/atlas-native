import SwiftUI
import AtlasCore

// File status symbol — peel de AtlasCodeFileRow+Meta.

extension AtlasCodeFileRow {
    var symbol: String {
        switch file.status {
        case .added: return "plus"
        case .modified: return "pencil"
        case .deleted: return "minus"
        case .renamed: return "arrow.right"
        case .copied: return "doc.on.doc"
        case .typeChanged: return "arrow.triangle.2.circlepath"
        case .unknown: return "questionmark"
        }
    }
}
