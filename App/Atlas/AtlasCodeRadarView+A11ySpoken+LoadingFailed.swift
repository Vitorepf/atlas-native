import SwiftUI
import AtlasCore

// Loading + failed spoken — peel de AtlasCodeRadarView+A11ySpoken.

extension AtlasCodeRadarView {
    func spokenLoading() -> String { "lendo o workspace" }

    func spokenFailed(_ message: String) -> String {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "workspace indisponível" }
        return "workspace indisponível, \(trimmed)"
    }
}
