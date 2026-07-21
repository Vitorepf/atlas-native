import Foundation

// MARK: - Types

/// Exclusive cache-read honesty face (WAVE-060).
enum ConversationStaleReadFace: Equatable {
    case confirming
    case fresh
    case aged
    case stale

    var productWord: String {
        switch self {
        case .confirming: return "confirming"
        case .fresh: return "fresh"
        case .aged: return "aged"
        case .stale: return "stale"
        }
    }

    var spokenFace: String {
        switch self {
        case .confirming: return "histórico salvo atualizado"
        case .fresh: return "leitura recente em cache"
        case .aged: return "leitura envelhecendo em cache"
        case .stale: return "leitura envelhecida em cache"
        }
    }
}

// MARK: - Judgment

/// Pure stale-read seal grammar — face · caption · spoken · pack.
enum ConversationStaleReadJudgment {

    /// Fresh < 5m · aged < 1h · stale ≥ 1h (display buckets only).
    static func face(
        capturedAt: Date,
        now: Date = Date(),
        confirming: Bool
    ) -> ConversationStaleReadFace {
        if confirming { return .confirming }
        let seconds = max(0, Int(now.timeIntervalSince(capturedAt)))
        if seconds < 5 * 60 { return .fresh }
        if seconds < 60 * 60 { return .aged }
        return .stale
    }

    static func displayCaption(
        capturedAt: Date,
        now: Date = Date(),
        confirming: Bool,
        reduceMotion: Bool
    ) -> String {
        if confirming {
            return reduceMotion ? "leitura atualizada" : "leitura sincronizada"
        }
        return "visto há \(atlasRelativeAgePT(since: capturedAt, now: now))"
    }

    static func spokenLabel(
        capturedAt: Date,
        now: Date = Date(),
        confirming: Bool,
        reduceMotion: Bool
    ) -> String {
        let face = face(capturedAt: capturedAt, now: now, confirming: confirming)
        if confirming {
            return reduceMotion
                ? "histórico salvo atualizado"
                : "histórico salvo atualizado após sincronizar"
        }
        let age = atlasRelativeAgePT(since: capturedAt, now: now)
        return "histórico salvo visto há \(age), \(face.spokenFace)"
    }

    static func packFacts(
        capturedAt: Date?,
        now: Date = Date(),
        confirming: Bool = false
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        guard let capturedAt else {
            absences.append("sem captura de cache neste recorte")
            return (facts, absences)
        }
        let face = face(capturedAt: capturedAt, now: now, confirming: confirming)
        facts.append("stale_read_face: \(face.productWord)")
        facts.append("cache_age_s: \(max(0, Int(now.timeIntervalSince(capturedAt))))")
        if confirming {
            facts.append("cache_confirming: true")
        }
        return (facts, absences)
    }
}
