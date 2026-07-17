import Foundation
import AtlasCore

/// Spoken labels das linhas do radar — peel de AtlasCodeRadarRows (CICLO C).
/// Desvios só com `issues` publicados; nil = silêncio, nunca fabrica limpo.

enum AtlasCodeRadarRowsA11y {
    static let repoHint = "abre o grafo do repositório"

    static func spokenRepo(
        name: String,
        folder: String?,
        showsFolder: Bool,
        issues: [AtlasCodeIssue]?,
        trunk: String?,
        lastCommitAt: String?
    ) -> String {
        var parts = [name]
        if showsFolder, let folder, !folder.isEmpty {
            parts.append("pasta \(folder)")
        }
        if let issues, !issues.isEmpty {
            if let first = issues.first {
                parts.append(first.headline(trunk: trunk))
                if first.isSevere { parts.append("alta severidade") }
            }
            if issues.count > 1 {
                let more = issues.count - 1
                parts.append("mais \(more) desvio\(more == 1 ? "" : "s")")
            }
        }
        if let age = AtlasCodeAge.short(from: lastCommitAt) {
            parts.append("último commit \(age)")
        }
        return parts.joined(separator: ", ")
    }
}
