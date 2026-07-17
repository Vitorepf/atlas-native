import Foundation
import AtlasCore

/// Mutate verbs — peel de AtlasCodeFileRow+A11yVerb.

extension AtlasCodeFileRowA11y {
    static func verbMutate(for status: AtlasCodeFileStatus) -> String? {
        switch status {
        case .added: return "adicionado"
        case .modified: return "alterado"
        case .deleted: return "removido"
        default: return nil
        }
    }
}
