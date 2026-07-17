import SwiftUI
import AtlasCore

// Spoken helpers — peel de AtlasCodeRadarView+A11y.

extension AtlasCodeRadarView {
    func spokenLoading() -> String { "lendo o workspace" }

    func spokenFailed(_ message: String) -> String {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "workspace indisponível" }
        return "workspace indisponível, \(trimmed)"
    }

    func spokenEmptyWorkspace() -> String { "nenhum repositório neste workspace" }

    static let shellHint = "pastas, recentes e desvios verificados do seu código"
}
