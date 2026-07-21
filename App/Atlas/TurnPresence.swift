import Foundation
import AtlasCore
import SwiftUI
import ActivityKit

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

// MARK: - TurnPresenceActivity

#if canImport(ActivityKit)
#endif

@MainActor
// MARK: - Broadcast / lifecycle
extension TurnPresence {
    func broadcastCount() {
        #if canImport(ActivityKit)
        let count = activeCount
        Task { @MainActor in
            for a in Activity<AtlasTurnAttributes>.activities {
                let s = a.content.state
                guard !s.finished, s.activeSessions != max(1, count) else { continue }
                var next = s
                next.activeSessions = max(1, count)   // preserva fase, timer e pausa
                await a.update(.init(state: next, staleDate: nil))
            }
        }
        #endif
    }
}

#if canImport(ActivityKit)
#endif

@MainActor
// MARK: - End activities
extension TurnPresence {
    func endActivities(
        key: TraceID,
        state: AtlasTurnAttributes.ContentState,
        model: ConversationModel?,
        closed: Bool
    ) {
        #if canImport(ActivityKit)
        Task { @MainActor in
            for a in Activity<AtlasTurnAttributes>.activities where a.attributes.threadKey == key.rawValue {
                LiveActivityRemoteBridge.shared.end(
                    activityID: a.id,
                    model: model,
                    reason: closed ? "session_closed" : "completed"
                )
                await a.end(.init(state: state, staleDate: nil),
                            dismissalPolicy: .after(.now + 4))
            }
        }
        #endif
    }
}

#if canImport(ActivityKit)
#endif

@MainActor
// MARK: - Finish activity
extension TurnPresence {
    func finishActivity(_ entry: Entry, presence: AtlasExecutionPresence?,
                        phaseOverride: String? = nil) {
        #if canImport(ActivityKit)
        guard let key = entry.activityKey else { return }
        let progress = entry.model?.bubbles.last(where: { $0.traceId == key })?.executionProgress
        let state = contentState(entry, presence: presence, finished: true,
                                 phaseOverride: phaseOverride, progress: progress)
        endActivities(
            key: key,
            state: state,
            model: entry.model,
            closed: phaseOverride == "sessão encerrada"
        )
        entry.activityStarted = false
        entry.activityKey = nil
        #endif
    }

}



#if canImport(ActivityKit)
#endif

@MainActor
// MARK: - Update activity
extension TurnPresence {
    func updateActivity(_ entry: Entry, presence: AtlasExecutionPresence,
                        phaseOverride: String? = nil) {
        #if canImport(ActivityKit)
        guard let key = entry.activityKey else { return }
        let progress = entry.model?.bubbles.last(where: { $0.traceId == key })?.executionProgress
        let state = contentState(entry, presence: presence, finished: false, phaseOverride: phaseOverride, progress: progress)
        Task { @MainActor in
            for a in Activity<AtlasTurnAttributes>.activities where a.attributes.threadKey == key.rawValue {
                await a.update(.init(state: state, staleDate: nil))
            }
        }
        #endif
    }
}

#if canImport(ActivityKit)
#endif

@MainActor
extension TurnPresence {

// MARK: - Start activity
    func startActivity(_ entry: Entry, traceId: TraceID, presence: AtlasExecutionPresence,
                       phaseOverride: String? = nil) {
        #if canImport(ActivityKit)
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        entry.activityKey = traceId
        let progress = entry.model?.bubbles.last(where: { $0.traceId == traceId })?.executionProgress
        let state = contentState(entry, presence: presence, finished: false, phaseOverride: phaseOverride, progress: progress)
        guard let activity = try? Activity.request(
            attributes: AtlasTurnAttributes(threadTitle: entry.threadTitle, threadKey: traceId.rawValue),
            content: .init(state: state, staleDate: nil),
            pushType: .token
        ) else { entry.activityKey = nil; return }
        entry.activityStarted = true
        LiveActivityRemoteBridge.shared.observePushTokens(
            activity: activity,
            model: entry.model!,
            startedAt: entry.startedAt
        )
        #endif
    }

}

@MainActor
// MARK: - Clock / timing
extension TurnPresence {
    static func clock(_ ms: Int) -> String {
        AtlasTime.formatActiveDuration(milliseconds: ms)
    }
}

@MainActor
extension TurnPresence {
    static func timingAnchor(
        entry: Entry,
        presence p: AtlasExecutionPresence?,
        finished: Bool
    ) -> (started: Date, paused: Bool?, pausedDisplay: String?) {
        var started = entry.startedAt
        var paused: Bool? = nil
        var pausedDisplay: String? = nil
        if let p {
            if let since = p.runningSince {
                started = since.addingTimeInterval(-Double(p.elapsedActiveMilliseconds ?? 0) / 1000)
            } else if p.isTimerPaused {
                paused = true
                pausedDisplay = p.elapsedActiveMilliseconds.map(clock)
            }
            if finished, let ms = p.elapsedActiveMilliseconds {
                pausedDisplay = clock(ms)
            }
        }
        if started > Date() { started = Date() }
        return (started, paused, pausedDisplay)
    }
}

#if canImport(ActivityKit)
#endif

@MainActor
// MARK: - Content state
extension TurnPresence {
    func contentState(_ entry: Entry, presence p: AtlasExecutionPresence?,
                      finished: Bool, phaseOverride: String? = nil,
                      progress: AtlasExecutionPlan.Progress? = nil)
        -> AtlasTurnAttributes.ContentState {
        let timing = Self.timingAnchor(entry: entry, presence: p, finished: finished)
        return AtlasTurnAttributes.ContentState(
            phaseTitle: phaseOverride ?? p?.phaseTitle ?? (finished ? "resposta pronta" : "Executando"),
            startedAt: timing.started,
            finished: finished,
            activeSessions: max(finished ? 0 : 1, activeCount),
            paused: timing.paused,
            pausedDisplay: timing.pausedDisplay,
            progressCurrent: progress?.current,
            progressTotal: progress?.total,
            queuedCount: entry.model?.queuedMessages.count)
    }
}

@MainActor
// MARK: - Live session publish
extension TurnPresence {
    func liveSessionSnapshot(from entry: Entry) -> LiveSessionSnapshot? {
        guard let model = entry.model,
              let presence = model.currentExecutionPresence,
              let trace = model.currentExecutionPresenceTraceId else { return nil }
        return LiveSessionSnapshot(
            id: trace.rawValue,
            threadId: entry.threadId ?? model.threadId,
            title: entry.threadTitle,
            phaseTitle: liveSessionPhaseTitle(model: model, trace: trace, presence: presence),
            timing: presence.timing,
            elapsedActiveMs: presence.elapsedActiveMilliseconds,
            runningSince: presence.runningSince,
            pauseTimestamp: presence.pauseTimestamp,
            startedAt: entry.startedAt,
            isRemote: false
        )
    }
}

@MainActor
extension TurnPresence {
    func liveSessionPhaseTitle(model: ConversationModel, trace: TraceID, presence: AtlasExecutionPresence) -> String {
        var phase = presence.phaseTitle
        if presence.timing == .running,
           let prog = model.bubbles.last(where: { $0.traceId == trace })?.executionProgress {
            phase = "\(prog.current)/\(prog.total) · \(prog.title)"
        }
        return phase
    }
}

@MainActor
extension TurnPresence {
    func publishLiveSessions() {
        var byTrace: [String: LiveSessionSnapshot] = [:]
        for entry in entries.values where entry.ongoing {
            guard let snap = liveSessionSnapshot(from: entry) else { continue }
            byTrace[snap.id] = snap
        }
        liveSessions = byTrace.values.sorted { $0.startedAt < $1.startedAt }
    }
}

// WAVE-102: away notification grammar → TurnPresenceJudgment (A11y soup deleted)

// MARK: - LiveActivityRemoteBridge

#if canImport(ActivityKit)

extension LiveActivityRemoteBridge {
    func end(activityID: String, model: ConversationModel?, reason: String) {
        locallyManagedActivityIDs.remove(activityID)
        tokenTasks[activityID]?.cancel()
        tokenTasks[activityID] = nil
        guard let traceId = tracesByActivityID.removeValue(forKey: activityID), let model else { return }
        Task { @MainActor in
            await model.invalidateLiveActivityPushToken(
                traceId: traceId,
                activityId: activityID,
                reason: reason
            )
        }
    }
}
#endif

#if canImport(ActivityKit)

extension LiveActivityRemoteBridge {
    func observePushTokens(
        activity: Activity<AtlasTurnAttributes>,
        model: ConversationModel,
        startedAt: Date
    ) {
        locallyManagedActivityIDs.insert(activity.id)
        tokenTasks[activity.id]?.cancel()
        tokenTasks[activity.id] = Task { @MainActor [weak self, weak model] in
            guard let self, let model else { return }
            for await token in activity.pushTokenUpdates {
                guard !Task.isCancelled,
                      let traceId = await self.waitForTrace(model),
                      let receipt = await model.registerLiveActivityPushToken(
                        traceId: traceId,
                        activityId: activity.id,
                        pushToken: token.atlasHex,
                        environment: Self.environment,
                        startedAt: startedAt,
                        frequentUpdatesEnabled: ActivityAuthorizationInfo().frequentPushesEnabled
                      )
                else { continue }

                self.tracesByActivityID[activity.id] = TraceID(receipt.traceId)
            }
        }
    }
}
#endif

#if canImport(ActivityKit)

extension LiveActivityRemoteBridge {
    func waitForTrace(_ model: ConversationModel) async -> TraceID? {
        for _ in 0..<30 {
            if let traceId = model.currentStreamingTraceId { return traceId }
            guard model.isSending else { return nil }
            try? await Task.sleep(for: .milliseconds(100))
        }
        return nil
    }

    static var environment: AtlasLiveActivityRegistrationInput.Environment {
        #if DEBUG
        .sandbox
        #else
        .production
        #endif
    }
}
#endif

#if canImport(ActivityKit)
extension Data {
    var atlasHex: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
#endif

#if canImport(ActivityKit)

extension LiveActivityRemoteBridge {
    func bootstrap(client: AtlasClient, installationId: String) {
        bootstrapStartToken(client: client, installationId: installationId)
        bootstrapRemoteActivities(client: client, installationId: installationId)
    }
}
#endif

#if canImport(ActivityKit)

extension LiveActivityRemoteBridge {
    func bootstrapStartToken(client: AtlasClient, installationId: String) {
        guard #available(iOS 17.2, *), startTokenTask == nil else { return }
        startTokenTask = Task { @MainActor [weak self] in
            guard self != nil else { return }
            for await token in Activity<AtlasTurnAttributes>.pushToStartTokenUpdates {
                guard !Task.isCancelled else { break }
                _ = try? await client.registerLiveActivityStartToken(.init(
                    installationId: installationId,
                    pushToken: token.atlasHex,
                    environment: Self.environment
                ))
            }
        }
    }
}
#endif

#if canImport(ActivityKit)

extension LiveActivityRemoteBridge {
    func bootstrapRemoteActivities(client: AtlasClient, installationId: String) {
        guard #available(iOS 17.2, *), remoteActivityTask == nil else { return }
        remoteActivityTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for await activity in Activity<AtlasTurnAttributes>.activityUpdates {
                guard !Task.isCancelled else { break }
                guard !self.locallyManagedActivityIDs.contains(activity.id) else { continue }
                self.observeRemotelyStartedActivity(activity, client: client, installationId: installationId)
            }
        }
    }

    func observeRemotelyStartedActivity(
        _ activity: Activity<AtlasTurnAttributes>,
        client: AtlasClient,
        installationId: String
    ) {
        tokenTasks[activity.id]?.cancel()
        tokenTasks[activity.id] = Task { @MainActor [weak self] in
            guard let self else { return }
            let traceId = activity.attributes.threadKey
            for await token in activity.pushTokenUpdates {
                guard !Task.isCancelled else { break }
                let receipt = try? await client.registerLiveActivity(.init(
                    traceId: traceId,
                    activityId: activity.id,
                    installationId: installationId,
                    pushToken: token.atlasHex,
                    environment: Self.environment,
                    startedAt: activity.content.state.startedAt,
                    frequentUpdatesEnabled: ActivityAuthorizationInfo().frequentPushesEnabled
                ))
                if receipt != nil {
                    self.tracesByActivityID[activity.id] = TraceID(traceId)
                }
            }
        }
    }
}
#endif

#if canImport(ActivityKit)

@MainActor
final class LiveActivityRemoteBridge {
    static let shared = LiveActivityRemoteBridge()
    private init() {}

    var tokenTasks: [String: Task<Void, Never>] = [:]
    var tracesByActivityID: [String: TraceID] = [:]
    var locallyManagedActivityIDs: Set<String> = []
    var startTokenTask: Task<Void, Never>?
    var remoteActivityTask: Task<Void, Never>?
}
#endif

// MARK: - AtlasTokenStore

enum AtlasTokenStore {
    private static let service = "com.vitor.atlas.native"
    private static let account = "ATLAS_TOKEN"

    static func resolve(configuredToken: String) -> String {
        let trimmed = configuredToken.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            save(trimmed)
            return trimmed
        }
        return load() ?? ""
    }

    private static func load() -> String? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let token = String(data: data, encoding: .utf8),
              !token.isEmpty else { return nil }
        return token
    }

    private static func save(_ token: String) {
        guard let data = token.data(using: .utf8) else { return }
        var query = baseQuery()
        let attributes = [kSecValueData as String: data]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            query[kSecValueData as String] = data
            query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            _ = SecItemAdd(query as CFDictionary, nil)
        }
    }

    private static func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }
}
