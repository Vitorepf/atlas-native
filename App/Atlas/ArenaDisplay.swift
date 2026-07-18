import Foundation

/// Nomes de exibição e datas relativas da Arena — presentation-only.
/// IDs crus continuam nos contratos e nos A11y identifiers; o operador
/// nunca lê snake_case nem ISO 8601 cru.
enum ArenaDisplay {
    private static let engines: [String: String] = [
        "codex_cli": "Codex CLI",
        "claude_code": "Claude Code",
        "verboo_kimi_k2_7": "Kimi K2.7 · Verboo",
        "hermes": "Hermes",
    ]

    private static let suites: [String: String] = [
        "terminal_bench": "Terminal Bench",
        "inspect_evals": "Inspect Evals",
        "tau2_bench": "τ²-Bench",
        "bfcl": "BFCL · Funções",
        "senior_swe_bench": "Senior SWE",
        "swe_bench_live": "SWE Live",
        "live_code_bench": "LiveCodeBench",
        "hal_harness": "HAL Harness",
        "aider_polyglot": "Aider Polyglot",
        "swe_marathon": "SWE Marathon",
    ]

    static func engine(_ id: String) -> String {
        engines[id] ?? humanized(id)
    }

    /// Origem do run (`iphone|ipad|mac|cli`) → rótulo humano; nil = não dita.
    static func origin(_ id: String?) -> String? {
        switch id {
        case "iphone": return "iPhone"
        case "ipad": return "iPad"
        case "mac": return "Mac"
        case "cli": return "CLI"
        default: return nil
        }
    }

    static func suite(_ id: String) -> String {
        suites[id] ?? humanized(id)
    }

    /// Fallback genérico: snake_case → Palavras Capitalizadas.
    private static func humanized(_ id: String) -> String {
        id.split(separator: "_")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }

    /// "2026-07-16T23:42:29+00:00" → "há 2h"; nil se não parsear (nunca ISO cru).
    static func relative(_ isoString: String?) -> String? {
        guard let isoString, let date = parseISO(isoString) else { return nil }
        let seconds = max(0, Int(Date().timeIntervalSince(date)))
        switch seconds {
        case ..<60: return "agora"
        case ..<3600: return "há \(seconds / 60)min"
        case ..<86_400: return "há \(seconds / 3600)h"
        default: return "há \(seconds / 86_400)d"
        }
    }

    // ISO8601DateFormatter não é Sendable — instância por chamada (barato aqui).
    private static func parseISO(_ string: String) -> Date? {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return fractional.date(from: string) ?? ISO8601DateFormatter().date(from: string)
    }
}
