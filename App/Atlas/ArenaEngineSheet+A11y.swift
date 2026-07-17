import Foundation
import AtlasCore

// Spoken labels — peel de ArenaEngineSheet (CICLO C residual honesty).
// Composto/multiplicador só com valores publicados; gráfico decorativo.
// Sheet → ArenaEngineSheet+A11ySheet.swift
// Summary → ArenaEngineSheet+A11ySummary.swift

enum ArenaEngineSheetA11y {
    static func spokenEngineTitle(_ engine: String) -> String {
        "motor \(engine)"
    }

    static func spokenCapabilities(_ capabilities: AtlasArenaCapabilities?) -> String {
        let count = capabilities?.capabilities.count ?? 0
        if count == 0 { return "sem capacidades medidas publicadas" }
        if count == 1 { return "1 capacidade medida" }
        return "\(count) capacidades medidas"
    }

    static let closeLabel = "fechar detalhes do motor"
    static let closeHint = "volta para a Arena"
}
