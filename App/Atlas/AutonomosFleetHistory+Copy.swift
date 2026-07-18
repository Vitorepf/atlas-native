import Foundation
import AtlasCore

// Tradução dos eventos crus da frota para linguagem do operador.
// Slug desconhecido = mostrado como veio (nunca inventar significado).

enum AutonomosFleetHistoryCopy {
    static func event(_ raw: String) -> String {
        switch raw {
        case "started": return "iniciado"
        case "stopped": return "parado"
        case "restarted": return "reiniciado"
        case "desired_on": return "ligado por você"
        case "desired_off": return "desligado por você"
        case "crashed": return "caiu"
        default: return raw.replacingOccurrences(of: "_", with: " ")
        }
    }

    static func reason(_ raw: String) -> String {
        switch raw {
        case "not_desired": return "não desejado — decisão sua"
        case "not_authorized": return "sem autorização de gasto"
        case "panic_off_all_via_app": return "pânico — tudo desligado pelo app"
        case "operator_no_codex_spend": return "gasto Codex vetado por você"
        default: return raw.replacingOccurrences(of: "_", with: " ")
        }
    }

    /// "2026-07-03 17:39:07" ou ISO → "há 2 semanas"; sem parse, cru.
    static func when(_ raw: String) -> String {
        let iso = raw.contains("T") ? raw : raw.replacingOccurrences(of: " ", with: "T")
        guard let date = AtlasTime.date(iso) ?? plainFormatter.date(from: iso) else { return raw }
        return "há \(AutonomosChrome.relativeAge(from: date))"
    }

    /// Timestamps do servidor sem timezone (UTC implícito) — o ISO8601 puro
    /// rejeita; na granularidade relativa ("há 2 semanas") o desvio é nulo.
    private static let plainFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
}
