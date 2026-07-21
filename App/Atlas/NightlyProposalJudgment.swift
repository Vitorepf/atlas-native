import Foundation

// MARK: - Types

/// Exclusive nightly proposal organ face (WAVE-070).
enum NightlyProposalFace: Equatable {
    case pending
    case muted
    case mutedAuto
    case hidden

    var productWord: String {
        switch self {
        case .pending: return "pending"
        case .muted: return "muted"
        case .mutedAuto: return "muted_auto"
        case .hidden: return "hidden"
        }
    }

    var spokenFace: String {
        switch self {
        case .pending:
            return "missão noturna proposta"
        case .muted:
            return "propostas noturnas em pausa"
        case .mutedAuto:
            return "propostas em pausa após recusas"
        case .hidden:
            return "sem proposta noturna"
        }
    }
}

// MARK: - Judgment

/// Pure nightly-proposal grammar — face · spoken · pack.
enum NightlyProposalJudgment {

    static let dismissStreakPauseThreshold = 3
    static let muteDays: [Int] = [1, 3, 7]

    static func face(
        hasPending: Bool,
        isMuted: Bool,
        autoPaused: Bool
    ) -> NightlyProposalFace {
        if isMuted {
            return autoPaused ? .mutedAuto : .muted
        }
        if hasPending { return .pending }
        return .hidden
    }

    static func spokenCardLabel(workspaceText: String) -> String {
        "missão noturna proposta. Hoje você trabalhou em \(workspaceText). "
            + "A frota pode continuar enquanto você descansa."
    }

    static let spokenCardHint = "preparar, descartar em silêncio ou pausar por dias"
    static let spokenAcceptLabel = "preparar missão noturna"
    static let spokenAcceptHint = "abre o ensaio governado da missão noturna"
    static let spokenDismissLabel = "hoje não"
    static let spokenDismissHint = "descarta a proposta em silêncio, sem confirmação"
    static let spokenMuteMenuLabel = "pausar propostas noturnas"
    static let spokenMuteMenuHint =
        "oculta card e notificações por 1, 3 ou 7 dias; propostas ficam em pausa"

    static func spokenMuteOption(days: Int) -> String {
        "pausar por \(days) \(days == 1 ? "dia" : "dias")"
    }

    static let spokenMuteOptionHint =
        "remove a proposta e pausa notificações, sem toast"

    /// Relative mute status for a11y when muted (nil when not muted).
    static func spokenMuteStatus(
        isMuted: Bool,
        mutedUntil: Date?,
        autoPaused: Bool,
        now: Date = .init(),
        relativePrazo: (Date, Date) -> String
    ) -> String? {
        guard isMuted, let until = mutedUntil else { return nil }
        let prazo = relativePrazo(until, now)
        if autoPaused {
            return "propostas em pausa — você recusou as últimas \(dismissStreakPauseThreshold); voltam \(prazo)"
        }
        return "propostas noturnas em pausa até \(prazo)"
    }

    static func packFacts(
        hasPending: Bool,
        isMuted: Bool,
        autoPaused: Bool,
        workspaceText: String?,
        mutedUntil: Date?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(hasPending: hasPending, isMuted: isMuted, autoPaused: autoPaused)
        facts.append("nightly_face: \(face.productWord)")
        switch face {
        case .pending:
            if let workspaceText, !workspaceText.isEmpty {
                facts.append("nightly_workspaces: \(workspaceText)")
            } else {
                absences.append("proposta sem workspaces publicados")
            }
        case .muted, .mutedAuto:
            absences.append("propostas noturnas mutadas")
            if let mutedUntil {
                facts.append("nightly_muted_until_s: \(Int(mutedUntil.timeIntervalSince1970))")
            }
            if autoPaused {
                facts.append("nightly_auto_paused: true")
            }
        case .hidden:
            absences.append("sem proposta noturna neste recorte")
        }
        return (facts, absences)
    }
}
