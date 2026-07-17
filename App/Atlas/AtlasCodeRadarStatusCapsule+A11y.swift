import AtlasCore
import SwiftUI

// Spoken labels do radar — peel de AtlasCodeRadarStatusCapsule (CICLO C residual).

extension AtlasCodeRadarStatusCapsule {
    /// Frota quieta = caption mínima; alarme só com violação verificada no scan.
    func spokenStatus(model: AtlasCodeWorkspaceModel) -> String {
        switch model.scanState {
        case .clean:
            return "código quieto, nada pede você"
        case .unknown:
            return model.headline
        case .violating:
            return "atenção, \(model.headline)"
        }
    }
}

extension AtlasCodeRepoRow {
    func spokenRepoLabel(
        name: String,
        issues: [AtlasCodeIssue]?,
        trunk: String?,
        lastCommitAt: String?
    ) -> String {
        var parts = [name]
        if let issues, !issues.isEmpty {
            parts.append(issues.map { $0.headline(trunk: trunk) }.joined(separator: ", "))
        }
        if let age = AtlasCodeAge.short(from: lastCommitAt) {
            parts.append("último commit \(age)")
        }
        return parts.joined(separator: ", ")
    }
}
