import Foundation
import AtlasCore

// MARK: - Judgment

/// Pure turn-presence away-notification grammar (WAVE-102).
/// Casca only — no UNUserNotificationCenter / UIKit side effects here.
enum TurnPresenceJudgment {

    // MARK: Terminal

    static func isTerminal(_ presence: AtlasExecutionPresence) -> Bool {
        presence.timing == .finished
            && (presence.phaseTitle == "Concluído" || presence.phaseTitle == "Falhou")
    }

    static func title(from presence: AtlasExecutionPresence) -> String {
        presence.phaseTitle
    }

    // MARK: Body / spoken

    static func body(
        presence: AtlasExecutionPresence,
        assistantExcerpt: String?,
        presentationDetail: String?
    ) -> String? {
        switch presence.phaseTitle {
        case "Falhou":
            guard let detail = presentationDetail?
                .trimmingCharacters(in: .whitespacesAndNewlines), !detail.isEmpty else { return nil }
            return lockScreenText(detail, limit: 140)
        case "Concluído":
            guard let excerpt = assistantExcerpt?
                .trimmingCharacters(in: .whitespacesAndNewlines), !excerpt.isEmpty else { return nil }
            return lockScreenText(AtlasMarkdown.plainText(excerpt), limit: 140)
        default:
            return nil
        }
    }

    static func spoken(title: String, subtitle: String, body: String?) -> String {
        guard let body, !body.isEmpty else { return "\(title), \(subtitle)" }
        return "\(title), \(subtitle). \(body)"
    }

    /// Collapse newlines + hard truncate for lock-screen surfaces.
    static func lockScreenText(_ value: String, limit: Int) -> String {
        let collapsed = value
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard collapsed.count > limit else { return collapsed }
        return String(collapsed.prefix(max(0, limit - 1))) + "…"
    }

    // MARK: Pack

    static func packFacts(
        presence: AtlasExecutionPresence?,
        liveSessionCount: Int
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        facts.append("live_sessions: \(liveSessionCount)")
        guard let presence else {
            absences.append("presence não publicada neste recorte")
            return (facts, absences)
        }
        facts.append("presence_phase: \(presence.phaseTitle)")
        let terminal = isTerminal(presence)
        facts.append("presence_terminal: \(terminal)")
        if !terminal {
            absences.append("notificação away só em terminal (Concluído/Falhou)")
        }
        return (facts, absences)
    }
}
