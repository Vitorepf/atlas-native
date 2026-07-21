import Foundation

/// Spoken labels — peel de NightlyProposal (CICLO C residual honesty).
/// Mute days → NightlyProposal+A11yMute.swift
/// Mute menu → NightlyProposal+A11yMuteMenu.swift
/// Actions → NightlyProposal+A11yActions.swift

extension NightlyProposalCard {
    static func spokenCardLabel(workspaceText: String) -> String {
        "missão noturna proposta. Hoje você trabalhou em \(workspaceText). "
            + "A frota pode continuar enquanto você descansa."
    }

    static func spokenCardHint() -> String {
        "preparar, descartar em silêncio ou silenciar por dias"
    }
}
