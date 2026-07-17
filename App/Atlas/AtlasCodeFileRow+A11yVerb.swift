import Foundation
import AtlasCore

/// File status verb — peel de AtlasCodeFileRow+A11y.

extension AtlasCodeFileRowA11y {
    static func verb(for status: AtlasCodeFileStatus) -> String {
        switch status {
        case .added: return "adicionado"
        case .modified: return "alterado"
        case .deleted: return "removido"
        case .renamed: return "renomeado"
        case .copied: return "copiado"
        case .typeChanged: return "tipo alterado"
        case .unknown: return "mudança desconhecida"
        }
    }
}
