import Foundation
import AtlasCore

/// Spoken labels da pasta do radar — peel de AtlasCodeFolderRow (CICLO C).
/// Desvios só de repos já varridos; nil de issues = silêncio, nunca conta limpo.
/// Hint → AtlasCodeRadarFolderRow+A11yHint.swift
/// Expanded → AtlasCodeRadarFolderRow+A11yFolderExpanded.swift

enum AtlasCodeFolderRowA11y {
    static func spokenFolder(
        name: String,
        repositoryCount: Int,
        verifiedExceptionCount: Int,
        isExpanded: Bool
    ) -> String {
        var parts = [name, spokenRepoCount(repositoryCount)]
        if verifiedExceptionCount > 0, let phrase = AtlasCodeFolderRowA11yExceptions.exceptionPhrase(verifiedExceptionCount) {
            parts.append(phrase)
        }
        if let expanded = spokenFolderExpanded(isExpanded) { parts.append(expanded) }
        return parts.joined(separator: ", ")
    }
}
