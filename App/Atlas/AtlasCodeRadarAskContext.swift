import Foundation

/// Pack de ocasião do Radar (workspace) — presentation-only.
/// Só fatos já no `AtlasCodeWorkspaceModel`; ausência é ausência.
enum AtlasCodeRadarAskContext {
    static let invite = "pergunte sobre o workspace"

    static var emptySuggestions: [String] {
        [
            "o que pede atenção no workspace?",
            "quais pastas têm sem retorno?",
            "por onde começar a curar?",
        ]
    }

    static func emptyPrompt(headline: String?) -> String {
        let line = headline?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !line.isEmpty, line != "lendo o workspace…" {
            return "workspace · \(line) — o que você quer saber?"
        }
        return invite
    }

    /// Facts prefix for the first turns — never invents scan results.
    @MainActor
    static func facts(model: AtlasCodeWorkspaceModel) -> String {
        var lines: [String] = [
            "surface: code-radar",
            "subject: workspace do operador",
        ]

        if let workspace = model.workspace {
            let folderCount = workspace.folders.count
            let recentCount = workspace.recents.count
            lines.append("folders: \(folderCount)")
            lines.append("recents: \(recentCount)")
            if let root = workspace.workspaceRoot, !root.isEmpty {
                lines.append("workspace_root: \(root)")
            } else if let slug = workspace.recents.first?.slug {
                lines.append("workspace_wire_fallback: \(slug) (primeiro recente)")
            } else {
                lines.append("absences: sem workspace_root nem recentes para o wire")
            }
        } else {
            lines.append("workspace: ainda não carregado")
            lines.append("absences: workspace wire nil até load")
        }

        let scanned = model.issuesBySlug.count
        let withIssues = model.issuesBySlug.values.filter { !$0.isEmpty }.count
        let totalIssues = model.issuesBySlug.values.flatMap { $0 }.reduce(0) { $0 + $1.count }
        if scanned > 0 {
            lines.append("repos_scanned: \(scanned)")
            lines.append("repos_with_sem_retorno: \(withIssues)")
            if totalIssues > 0 {
                lines.append("sem_retorno_signals: \(totalIssues)")
            }
            lines.append("headline: \(model.headline)")
        } else {
            lines.append("absences: nenhum scan de violações hidratado ainda")
        }

        if !model.failedSlugs.isEmpty {
            lines.append("repos_mute: \(model.failedSlugs.sorted().joined(separator: ", "))")
        }

        lines.append("intent: julgamento soberano do workspace; não inventar merges ou cures")
        return lines.joined(separator: "\n")
    }
}
