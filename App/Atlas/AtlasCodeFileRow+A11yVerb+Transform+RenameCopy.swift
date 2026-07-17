import Foundation
import AtlasCore

/// Rename/copy verbs — peel de AtlasCodeFileRow+A11yVerb+Transform.

extension AtlasCodeFileRowA11y {
    static func verbRenameCopy(for status: AtlasCodeFileStatus) -> String? {
        switch status {
        case .renamed: return "renomeado"
        case .copied: return "copiado"
        default: return nil
        }
    }
}
