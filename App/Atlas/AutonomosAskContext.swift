import Foundation
import AtlasCore

/// Pack de contexto Autônomos v9 — presentation-only; pack nunca na cara.
enum AutonomosAskContext {
    static func invite(destination: AutonomosDestination?, vestment: AutonomosHubVestment) -> String {
        switch destination {
        case .evolution:
            return "resuma isto"
        case .hub:
            break
        case nil:
            return "o que mudou hoje?"
        }
        switch vestment {
        case .live: return "o que ele fez hoje?"
        case .quiet: return "devo retomar?"
        }
    }

    static func emptySuggestions(destination: AutonomosDestination?) -> [String] {
        switch destination {
        case .evolution:
            return ["o que mudou hoje?", "o que ele melhorou?"]
        case .hub:
            return ["devo retomar?", "o que ele fez?"]
        case nil:
            return ["novo Autônomo", "o que mudou hoje?"]
        }
    }

    static func facts(unit: AutonomosUnit?, destination: AutonomosDestination?) -> String {
        var lines: [String] = [
            "Contexto Autônomos (ocasião). Pack local anexa sempre; intenção do operador pode pedir outro mundo — não bloqueie por silo.",
        ]
        if let unit {
            lines.append("Autônomo: \(unit.name).")
            lines.append("Carta: \(unit.charter)")
            lines.append(unit.paused ? "Estado: pausado." : "Estado: vivo no escopo local.")
            lines.append("Idade: \(unit.ageLabel).")
        } else {
            lines.append("Lista de Autônomos — nenhum aberto.")
        }
        if let destination {
            lines.append("Tela: \(destination.navTitle).")
        }
        lines.append("Create Server de Autônomo ainda pendente (§5); catálogo local pode sumir no kill do app.")
        lines.append("Pause/retomar/encerrar: controles da face; NL de chat ainda não autoriza tools de escrita no wire.")
        lines.append("Transfer/decide do motor não têm face nesta versão — não invente recibos de transferência.")
        return lines.joined(separator: "\n")
    }
}
