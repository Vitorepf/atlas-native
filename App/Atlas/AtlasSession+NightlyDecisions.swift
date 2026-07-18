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

    static let nightlyAcceptDelaysKey = "atlas.nightlyProposal.acceptDelays"

    /// Um aceite zera o streak de recusas — o ritmo voltou a acertar. O atraso
    /// entre proposta e aceite (minutos) alimenta a janela adaptativa.
    static func recordNightlyProposalAccept(delayMinutes: Int? = nil) {
        let defaults = UserDefaults.standard
        defaults.set(0, forKey: nightlyDismissStreakKey)
        defaults.set(defaults.integer(forKey: nightlyAcceptTotalKey) + 1, forKey: nightlyAcceptTotalKey)
        if let delayMinutes {
            var delays = defaults.array(forKey: nightlyAcceptDelaysKey) as? [Int] ?? []
            delays.append(min(max(delayMinutes, 0), 180))
            defaults.set(Array(delays.suffix(5)), forKey: nightlyAcceptDelaysKey)
        }
    }

    /// Janela adaptativa: mediana dos últimos atrasos de aceite, clampada a
    /// 0…60 min e arredondada a 5. Menos de 2 amostras ou < 5 min = ruído = 0.
    static func nightlyProposalAdjustmentMinutes() -> Int {
        let delays = (UserDefaults.standard.array(forKey: nightlyAcceptDelaysKey) as? [Int] ?? []).sorted()
        guard delays.count >= 2 else { return 0 }
        let median = delays[delays.count / 2]
        let rounded = (min(median, 60) / 5) * 5
        return rounded >= 5 ? rounded : 0
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
