import SwiftUI
import AtlasCore

// Mutate file symbols — peel de AtlasCodeFileRow+Meta+Symbol.

extension AtlasCodeFileRow {
    var symbolMutate: String? {
        switch file.status {
        case .added: return "plus"
        case .modified: return "pencil"
        case .deleted: return "minus"
        default: return nil
        }
    }
}
