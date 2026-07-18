import Foundation
import AtlasCore

// Recência real dos workspaces — presentation-only (ISO compara lexicográfico).

extension AtlasSession {
    /// Os N workspaces com atividade mais recente (updatedAt da thread mais nova).
    func recentWorkspaces(_ limit: Int) -> [Workspace] {
        let ranked = workspaces.sorted { a, b in
            (latestThreadActivity(inWorkspace: a.id) ?? "")
                > (latestThreadActivity(inWorkspace: b.id) ?? "")
        }
        return Array(ranked.prefix(limit))
    }

    private func latestThreadActivity(inWorkspace key: String) -> String? {
        threads(inWorkspace: key).map(\.updatedAt).max()
    }
}
