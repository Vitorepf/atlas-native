import Foundation
import AtlasCore

/// Spoken labels da pasta do radar — peel de AtlasCodeFolderRow (CICLO C).
/// Desvios só de repos já varridos; nil de issues = silêncio, nunca conta limpo.

enum AtlasCodeFolderRowA11y {
    static func spokenFolder(
        name: String,
        repositoryCount: Int,
        verifiedExceptionCount: Int,
        isExpanded: Bool
    ) -> String {
        let repos = repositoryCount == 1 ? "1 repositório" : "\(repositoryCount) repositórios"
        var parts = [name, repos]
        if verifiedExceptionCount > 0 {
            parts.append(
                "\(verifiedExceptionCount) desvio\(verifiedExceptionCount == 1 ? "" : "s") verificado\(verifiedExceptionCount == 1 ? "" : "s")"
            )
        }
        if isExpanded { parts.append("expandida") }
        return parts.joined(separator: ", ")
    }

    static func spokenHint(isExpanded: Bool) -> String {
        isExpanded ? "recolhe a pasta" : "expande a pasta"
    }
}
