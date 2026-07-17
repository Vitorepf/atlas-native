import Foundation
import AtlasCore

// Sheet spoken — peel de ArenaEngineSheetA11y.

extension ArenaEngineSheetA11y {
    static func spokenSheet(
        _ engine: AtlasArenaCompositeEngine,
        capabilities: AtlasArenaCapabilities?
    ) -> String {
        var parts = ["motor \(engine.engine)", spokenSummary(engine)]
        parts.append(spokenCapabilities(capabilities))
        return parts.joined(separator: ", ")
    }

    static let sheetHint = "composto e capacidades só com valores publicados pelo servidor"
}
