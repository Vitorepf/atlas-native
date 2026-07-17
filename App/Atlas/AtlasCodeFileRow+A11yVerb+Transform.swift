import Foundation
import AtlasCore

/// Transform verbs — peel de AtlasCodeFileRow+A11yVerb.
/// RenameCopy → AtlasCodeFileRow+A11yVerb+Transform+RenameCopy.swift

extension AtlasCodeFileRowA11y {
    static func verbTransform(for status: AtlasCodeFileStatus) -> String {
        if let rename = verbRenameCopy(for: status) { return rename }
        switch status {
        case .typeChanged: return "tipo alterado"
        case .unknown: return "mudança desconhecida"
        default: return verbMutate(for: status) ?? "mudança desconhecida"
        }
    }
}
