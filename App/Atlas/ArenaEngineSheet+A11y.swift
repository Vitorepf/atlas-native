import Foundation
import AtlasCore

// Spoken labels — peel de ArenaEngineSheet (CICLO C residual honesty).
// Composto/multiplicador só com valores publicados; gráfico decorativo.

enum ArenaEngineSheetA11y {
    static func spokenEngineTitle(_ engine: String) -> String {
        "motor \(engine)"
    }

    static func spokenSummary(_ engine: AtlasArenaCompositeEngine) -> String {
        var parts = ["composto \(ArenaFormat.score(engine.composite))"]
        if engine.withAtlasComposite != nil || engine.withoutAtlasComposite != nil {
            parts.append("com Atlas \(ArenaFormat.score(engine.withAtlasComposite))")
            parts.append("sem Atlas \(ArenaFormat.score(engine.withoutAtlasComposite))")
        }
        if let multiplier = engine.atlasMultiplier {
            parts.append("multiplicador \(ArenaFormat.multiplier(multiplier))")
        }
        if !engine.history.isEmpty {
            parts.append("\(engine.history.count) rodadas no gráfico")
        }
        return parts.joined(separator: ", ")
    }

    static func spokenCapabilities(_ capabilities: AtlasArenaCapabilities?) -> String {
        let count = capabilities?.capabilities.count ?? 0
        if count == 0 { return "sem capacidades medidas publicadas" }
        if count == 1 { return "1 capacidade medida" }
        return "\(count) capacidades medidas"
    }

    static let closeLabel = "fechar detalhes do motor"
    static let closeHint = "volta para a Arena"

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
