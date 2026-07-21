import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: TurnPresence fused

// MARK: - TurnPresence

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
// MARK: - TurnPresenceRuntime

@MainActor
extension TurnPresence {
    func notifyIfAway(_ entry: Entry, model: ConversationModel,
                      finalPresence: AtlasExecutionPresence?, traceId: TraceID?) {
        guard UIApplication.shared.applicationState != .active else { return }
        guard let presence = finalPresence,
              TurnPresenceJudgment.isTerminal(presence) else { return }

        let bubble = traceId.flatMap { key in
            model.bubbles.last(where: { $0.traceId == key })
        }
        let content = buildAwayNotificationContent(
            entry: entry,
            presence: presence,
            bubble: bubble
        )
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
    }
}

@MainActor
extension TurnPresence {
    func buildAwayNotificationContent(
        entry: Entry,
        presence: AtlasExecutionPresence,
        bubble: ChatBubble?
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = TurnPresenceJudgment.title(from: presence)
        content.subtitle = TurnPresenceJudgment.lockScreenText(entry.threadTitle, limit: 48)
        if let body = TurnPresenceJudgment.body(
            presence: presence,
            assistantExcerpt: bubble?.text,
            presentationDetail: bubble?.executionPresentationState?.detail
        ) {
            content.body = body
        }
        if !UIAccessibility.isReduceMotionEnabled { content.sound = .default }
        return content
    }
}

@MainActor
extension TurnPresence {
    static func lockScreenText(_ value: String, limit: Int) -> String {
        TurnPresenceJudgment.lockScreenText(value, limit: limit)
    }
}

@MainActor
extension TurnPresence {
    func requestPermissionOnce() async {
        guard !askedPermission else { return }
        askedPermission = true
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }
}

@MainActor
extension TurnPresence {
    func tick(_ id: ObjectIdentifier) {
        guard let entry = entries[id] else { return }
        guard let model = entry.model else { cleanup(id); return }
        let presence = model.currentExecutionPresence
        let trace = model.currentExecutionPresenceTraceId

        if let p = presence, let trace {
            var phase: String? = nil
            if p.timing == .running,
               let prog = model.bubbles.last(where: { $0.traceId == trace })?.executionProgress {
                phase = "\(prog.current)/\(prog.total) · \(prog.title)"
            }
            tickRunning(entry, model: model, trace: trace, presence: p, phase: phase)
        } else if entry.ongoing {
            tickFinished(entry, model: model)
        }
    }
}

@MainActor
extension TurnPresence {
    func tickFinished(_ entry: Entry, model: ConversationModel) {
        entry.ongoing = false
        let traceKey = entry.activityKey
        let final = lastPresence(model, key: traceKey)
        finishActivity(entry, presence: final)
        broadcastCount()
        if UIApplication.shared.applicationState == .active, !entry.visible {
            AtlasMotion.softImpact(reduceMotion: UIAccessibility.isReduceMotionEnabled)
        }
        Task { @MainActor in
            await requestPermissionOnce()
            notifyIfAway(entry, model: model, finalPresence: final, traceId: traceKey)
        }
        syncRunning()
    }

    func lastPresence(_ model: ConversationModel, key: TraceID?) -> AtlasExecutionPresence? {
        guard let key else { return nil }
        return model.bubbles.last(where: { $0.traceId == key })?.executionPresence
    }
}

@MainActor
extension TurnPresence {
    func tickRunning(_ entry: Entry, model: ConversationModel, trace: TraceID,
                     presence p: AtlasExecutionPresence, phase: String?) {
        if entry.activityKey != nil && entry.activityKey != trace {
            finishActivity(entry, presence: lastPresence(model, key: entry.activityKey))
        }
        if !entry.ongoing || !entry.activityStarted {
            if !entry.ongoing { entry.startedAt = Date() }
            entry.ongoing = true
            startActivity(entry, traceId: trace, presence: p, phaseOverride: phase)
            broadcastCount()
            syncRunning()
        } else {
            updateActivity(entry, presence: p, phaseOverride: phase)
        }
    }
}

extension TurnPresence {
    func cleanup(_ id: ObjectIdentifier) {
        guard let entry = entries.removeValue(forKey: id) else { return }
        if entry.ongoing { finishActivity(entry, presence: nil, phaseOverride: "sessão encerrada") }
        broadcastCount()
        syncRunning()
    }
}

extension TurnPresence {
    func observe(_ id: ObjectIdentifier) {
        guard let entry = entries[id], let model = entry.model else {
            cleanup(id); return
        }
        withObservationTracking {
            _ = model.currentExecutionPresenceTraceId
            _ = model.currentExecutionPresence?.phaseTitle
            _ = model.currentExecutionPresence?.timing
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.tick(id)
                self?.observe(id)
            }
        }
    }
}
