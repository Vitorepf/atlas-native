import Foundation
import AtlasCore

/// Spoken labels da linha de arquivo — peel de AtlasCodeFileRow (CICLO C).
/// Contagens só quando o payload publica; binário sem inventar linhas.
/// Verb → AtlasCodeFileRow+A11yVerb.swift

enum AtlasCodeFileRowA11y {
    static func spokenFile(_ file: AtlasCodeFileChange) -> String {
        var parts = [file.path, verb(for: file.status)]
        if let from = file.renamedFrom { parts.append("de \(from)") }
        if let additions = file.additions, let deletions = file.deletions {
            parts.append("\(additions) linhas adicionadas")
            parts.append("\(deletions) removidas")
        } else {
            parts.append("arquivo binário")
        }
        return parts.joined(separator: ", ")
    }
}
