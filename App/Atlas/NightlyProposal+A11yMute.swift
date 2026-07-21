import Foundation

// Mute spoken status — peel de NightlyProposal+A11y.

extension NightlyProposalController {
    func spokenMuteStatus(now: Date = .init()) -> String? {
        guard isMuted(now: now), let until = mutedUntil else { return nil }
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.unitsStyle = .full
        let prazo = formatter.localizedString(for: until, relativeTo: now)
        if AtlasSession.nightlyProposalAutoPaused() {
            return "propostas em pausa — você recusou as últimas \(Self.dismissStreakPauseThreshold); voltam \(prazo)"
        }
        return "propostas noturnas silenciadas até \(prazo)"
    }
}
