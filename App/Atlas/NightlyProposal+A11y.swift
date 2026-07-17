import Foundation

/// Spoken labels — peel de NightlyProposal (CICLO C residual honesty).
/// Mute → NightlyProposal+A11yMute.swift

extension NightlyProposalCard {
    static func spokenCardLabel(workspaceText: String) -> String {
        "missão noturna proposta. Hoje você trabalhou em \(workspaceText). "
            + "A frota pode continuar enquanto você descansa."
    }

    static func spokenCardHint() -> String {
        "preparar, descartar em silêncio ou silenciar por dias"
    }

    static func spokenAcceptLabel() -> String { "preparar missão noturna" }

    static func spokenAcceptHint() -> String {
        "abre o ensaio governado da missão noturna"
    }

    static func spokenDismissLabel() -> String { "hoje não" }

    static func spokenDismissHint() -> String {
        "descarta a proposta em silêncio, sem confirmação"
    }

    static func spokenMuteMenuLabel() -> String { "silenciar propostas noturnas" }

    static func spokenMuteMenuHint() -> String {
        "oculta card e notificações por 1, 3 ou 7 dias, em silêncio"
    }

    static func spokenMuteOption(days: Int) -> String {
        "silenciar por \(days) \(days == 1 ? "dia" : "dias")"
    }

    static func spokenMuteOptionHint() -> String {
        "remove a proposta e pausa notificações, sem toast"
    }
}
