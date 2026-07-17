import SwiftUI
import AtlasCore

// Empty shell spoken — peel de AtlasCodeRadarView+A11ySpoken.

extension AtlasCodeRadarView {
    func spokenEmptyWorkspace() -> String { "nenhum repositório neste workspace" }

    static let shellHint = "pastas, recentes e desvios verificados do seu código"
}
