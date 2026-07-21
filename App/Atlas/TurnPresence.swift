import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: TurnPresence + Judgment fused

// MARK: - Presence

extension TurnPresence {
    final class Entry {
        weak var model: ConversationModel?
        var threadTitle: String
        var threadId: ThreadID?
        var activityKey: TraceID?   // trace real que liga Activity ↔ conversa
        var activityStarted = false
        var ongoing = false        // C14: running OU paused — a sessão vive
        var visible = false
        var startedAt = Date()     // base local só para trace legado (timer nil)
        init(model: ConversationModel, threadTitle: String, threadId: ThreadID?) {
            self.model = model
            self.threadTitle = threadTitle
            self.threadId = threadId
        }
    }
}
extension TurnPresence {
    func watch(_ model: ConversationModel, threadTitle: String, threadId: ThreadID? = nil) {
        let id = ObjectIdentifier(model)
        if let existing = entries[id] {
            existing.threadTitle = threadTitle
            existing.threadId = threadId ?? model.threadId
            publishLiveSessions()
            return
        }
        let entry = Entry(model: model, threadTitle: threadTitle, threadId: threadId ?? model.threadId)
        entries[id] = entry
        observe(id)
    }

    func setVisible(_ model: ConversationModel, visible: Bool) {
        entries[ObjectIdentifier(model)]?.visible = visible
    }
}


@Observable @MainActor
final class TurnPresence {
    static let shared = TurnPresence()
    private init() {}

    private(set) var runningTitles: Set<String> = []

    var liveSessions: [LiveSessionSnapshot] = []

    @ObservationIgnored var entries: [ObjectIdentifier: Entry] = [:]
    @ObservationIgnored var askedPermission = false

    func syncRunning() {
        runningTitles = Set(entries.values.filter { $0.ongoing }.map { $0.threadTitle })
        publishLiveSessions()
        Task { await AtlasNativeSnapshotWriter.shared.write() }
    }

    var activeCount: Int { entries.values.filter { $0.ongoing }.count }
}

// MARK: - Judgment

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
