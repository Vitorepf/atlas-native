import Foundation
import AtlasCore

/// Transform verbs — peel de AtlasCodeFileRow+A11yVerb.

extension AtlasCodeFileRowA11y {
    static func verbTransform(for status: AtlasCodeFileStatus) -> String {
        switch status {
        case .renamed: return "renomeado"
        case .copied: return "copiado"
        case .typeChanged: return "tipo alterado"
        case .unknown: return "mudança desconhecida"
        default: return verbMutate(for: status) ?? "mudança desconhecida"
        }
    }
}
