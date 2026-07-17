import SwiftUI
import AtlasCore

// File subtitle — peel de AtlasCodeFileRow+Meta.

extension AtlasCodeFileRow {
    var subtitle: String? {
        if let from = file.renamedFrom { return "de \(from)" }
        return file.directory
    }
}
