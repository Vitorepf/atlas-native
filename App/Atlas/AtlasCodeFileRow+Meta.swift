import SwiftUI
import AtlasCore

// Symbol + subtitle — peel de AtlasCodeFileRow.

extension AtlasCodeFileRow {
    var subtitle: String? {
        if let from = file.renamedFrom { return "de \(from)" }
        return file.directory
    }

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
