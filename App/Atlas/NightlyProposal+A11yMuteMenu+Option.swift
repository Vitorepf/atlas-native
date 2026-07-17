import Foundation

// Mute option spoken — peel de NightlyProposal+A11yMuteMenu.

extension NightlyProposalCard {
    static func spokenMuteOption(days: Int) -> String {
        "silenciar por \(days) \(days == 1 ? "dia" : "dias")"
    }

    static func spokenMuteOptionHint() -> String {
        "remove a proposta e pausa notificações, sem toast"
    }
}
