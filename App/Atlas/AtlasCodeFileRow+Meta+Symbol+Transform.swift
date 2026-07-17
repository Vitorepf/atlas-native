import SwiftUI
import AtlasCore

// Transform symbols — peel de AtlasCodeFileRow+Meta+Symbol.

extension AtlasCodeFileRow {
    var symbolTransform: String? {
        switch file.status {
        case .renamed: return "arrow.right"
        case .copied: return "doc.on.doc"
        case .typeChanged: return "arrow.triangle.2.circlepath"
        default: return nil
        }
    }
}
