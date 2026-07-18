import Foundation

// Placar das propostas noturnas — o aprender-com-as-respostas do operador.
// Streak de recusas alimenta a pausa automática (NightlyProposal.dismissProposal);
// o placar total aparece na folha do ritmo (AutonomosRhythmSheet).

extension AtlasSession {
    static let nightlyDismissStreakKey = "atlas.nightlyProposal.dismissStreak"
    static let nightlyAcceptTotalKey = "atlas.nightlyProposal.acceptedTotal"
    static let nightlyDismissTotalKey = "atlas.nightlyProposal.dismissedTotal"
    static let nightlyAutoPausedKey = "atlas.nightlyProposal.autoPaused"

    /// Registra uma recusa e devolve o tamanho do streak consecutivo.
    @discardableResult
    static func recordNightlyProposalDismissal() -> Int {
        let defaults = UserDefaults.standard
        let streak = defaults.integer(forKey: nightlyDismissStreakKey) + 1
        defaults.set(streak, forKey: nightlyDismissStreakKey)
        defaults.set(defaults.integer(forKey: nightlyDismissTotalKey) + 1, forKey: nightlyDismissTotalKey)
        return streak
    }

    /// Um aceite zera o streak de recusas — o ritmo voltou a acertar.
    static func recordNightlyProposalAccept() {
        let defaults = UserDefaults.standard
        defaults.set(0, forKey: nightlyDismissStreakKey)
        defaults.set(defaults.integer(forKey: nightlyAcceptTotalKey) + 1, forKey: nightlyAcceptTotalKey)
    }

    static func resetNightlyProposalStreak() {
        UserDefaults.standard.set(0, forKey: nightlyDismissStreakKey)
    }

    static func nightlyProposalScore() -> (accepted: Int, dismissed: Int) {
        let defaults = UserDefaults.standard
        return (defaults.integer(forKey: nightlyAcceptTotalKey),
                defaults.integer(forKey: nightlyDismissTotalKey))
    }

    static func setNightlyProposalAutoPaused(_ paused: Bool) {
        UserDefaults.standard.set(paused, forKey: nightlyAutoPausedKey)
    }

    static func nightlyProposalAutoPaused() -> Bool {
        UserDefaults.standard.bool(forKey: nightlyAutoPausedKey)
    }
}
