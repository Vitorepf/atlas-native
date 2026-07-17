import Foundation
import AtlasCore

/// Spoken labels da pasta do radar — peel de AtlasCodeFolderRow (CICLO C).
/// Desvios só de repos já varridos; nil de issues = silêncio, nunca conta limpo.
/// Hint → AtlasCodeRadarFolderRow+A11yHint.swift

enum AtlasCodeFolderRowA11y {
    static func spokenFolder(
        name: String,
        repositoryCount: Int,
        verifiedExceptionCount: Int,
        isExpanded: Bool
    ) -> String {
        let repos = repositoryCount == 1 ? "1 repositório" : "\(repositoryCount) repositórios"
        var parts = [name, repos]
        if verifiedExceptionCount > 0, let phrase = AtlasCodeFolderRowA11yExceptions.exceptionPhrase(verifiedExceptionCount) {
            parts.append(phrase)
        }
        if isExpanded { parts.append("expandida") }
        return parts.joined(separator: ", ")
    }
}
