import Foundation

/// Mute menu spoken — peel de NightlyProposal+A11y.

extension NightlyProposalCard {
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
