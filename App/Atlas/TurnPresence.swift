import ActivityKit
import AtlasCore
import AtlasCore   // só tipos (AtlasExecutionPresence) — regra 4 da fronteira
import Foundation
import SwiftUI
import UIKit
import UserNotifications
import WidgetKit

// Cycle 044 fuse → TurnPresence.swift

// A presença dos turnos FORA do app — tela bloqueada e Dynamic Island
// (paridade Cursor): UMA Live Activity POR SESSÃO em execução, cada uma com o
// próprio timer; quando há mais de uma, todas mostram o contador ("× N").
// Notificação local quando uma resposta conclui com o app fora da tela.
//
// 100% casca: observa os models por withObservationTracking (zero edição na
// lógica), fala só com frameworks de apresentação do sistema (ActivityKit/
// UserNotifications — sem rede/JSON/storage). Limite honesto: sem push do
// servidor (fase APNs, §5 C8), a atualização em background vive da janela de
// execução do iOS (~30s) — cobre o turno típico; turnos longos concluem a
// notificação quando o app volta.
//

/// Snapshot de uma sessão viva observada neste processo.
struct LiveSessionSnapshot: Identifiable, Equatable {
    let id: String            // traceId corrente (estável por execução)
    let threadId: ThreadID?   // para Route.thread; nil se conversa nova local
    let title: String
    let phaseTitle: String
    let timing: AtlasExecutionPresence.Timing
    let elapsedActiveMs: Int?
    let runningSince: Date?
    let pauseTimestamp: Date?
    /// 1ª observação local — só ordenação; nunca exibido como duração.
    let startedAt: Date
    let isRemote: Bool
}

@Observable @MainActor
final class TurnPresence {
    static let shared = TurnPresence()
    private init() {}

    /// Títulos das conversas com turno executando AGORA — o hub lê isto para
    /// mostrar vida na lista (◆ pulsando na linha certa) sem tocar nos models.
    private(set) var runningTitles: Set<String> = []

    /// Sessões vivas ordenadas por `startedAt` — a home materializa "VIVO AGORA"
    /// só quando este array não está vazio (lei V1.1). Mutar só via `publishLiveSessions`.
    var liveSessions: [LiveSessionSnapshot] = []

    @ObservationIgnored var entries: [ObjectIdentifier: Entry] = [:]
    @ObservationIgnored var askedPermission = false

    func syncRunning() {
        runningTitles = Set(entries.values.filter { $0.ongoing }.map { $0.threadTitle })
        publishLiveSessions()
        Task { await AtlasNativeSnapshotWriter.shared.write() }
    }

    /// Quantas sessões vivem agora (running + paused — a verdade do contador).
    var activeCount: Int { entries.values.filter { $0.ongoing }.count }
}

extension TurnPresence {
    /// Um turno observado. Classe (não struct) para `weak model` no registro.
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

#if canImport(ActivityKit)
#endif


@MainActor
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

// ActivityKit start/update — fora do shell TurnPresence.

@MainActor
extension TurnPresence {
    // MARK: - Live Activities (uma por sessão; contador compartilhado)
    // Activity<T> não é Sendable no Swift 6 — nunca atravessa Task. Dentro das
    // Tasks, enumeramos ESTATICAMENTE filtrando por attributes.threadKey.

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
extension TurnPresence {
    /// ContentState a partir da presença tipada — o ÚNICO relógio permitido:
    /// com timer do servidor, o timer nativo parte de (runningSince − ativo
    /// acumulado) e mostra exatamente o tempo ATIVO; pausado congela o
    /// acumulado em texto; trace legado cai na base local sem fingir pausas.
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
    /// Reconstrói `liveSessions` a partir das entries ongoing. Dedup por
    /// traceId; conversa nova sem thread canônica fica sem navegação.
    func publishLiveSessions() {
        var byTrace: [String: LiveSessionSnapshot] = [:]
        for entry in entries.values where entry.ongoing {
            guard let snap = liveSessionSnapshot(from: entry) else { continue }
            byTrace[snap.id] = snap
        }
        liveSessions = byTrace.values.sorted { $0.startedAt < $1.startedAt }
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

    /// A presença final da bolha dona da Activity (fase "Concluído"/"Falhou").
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
    /// Model desalocado (conversa fechada): encerra a activity órfã com honestidade.
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

#if canImport(ActivityKit)
#endif


@MainActor
extension TurnPresence {
    /// Propaga o contador novo para TODAS as activities vivas, preservando a
    /// fase e o timer de cada uma (lê o estado atual e só troca o contador).
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

@MainActor
enum TurnPresenceNotificationA11y {
    static func isTerminal(_ presence: AtlasExecutionPresence) -> Bool {
        TurnPresenceNotificationA11yTerminal.isTerminal(presence)
    }

    static func title(from presence: AtlasExecutionPresence) -> String {
        TurnPresenceNotificationA11yTerminal.title(from: presence)
    }

    /// Corpo só com dado real: excerpt da bolha do trace ou `detail` do ledger.
    static func body(
        presence: AtlasExecutionPresence,
        assistantExcerpt: String?,
        presentationDetail: String?
    ) -> String? {
        TurnPresenceNotificationA11yBody.body(
            presence: presence,
            assistantExcerpt: assistantExcerpt,
            presentationDetail: presentationDetail
        )
    }

    static func spoken(title: String, subtitle: String, body: String?) -> String {
        TurnPresenceNotificationA11ySpoken.spoken(title: title, subtitle: subtitle, body: body)
    }
}

@MainActor
enum TurnPresenceNotificationA11yBody {
    /// Corpo só com dado real: excerpt da bolha do trace ou `detail` do ledger.
    static func body(
        presence: AtlasExecutionPresence,
        assistantExcerpt: String?,
        presentationDetail: String?
    ) -> String? {
        switch presence.phaseTitle {
        case "Falhou":
            guard let detail = presentationDetail?
                .trimmingCharacters(in: .whitespacesAndNewlines), !detail.isEmpty else { return nil }
            return TurnPresence.lockScreenText(detail, limit: 140)
        case "Concluído":
            guard let excerpt = assistantExcerpt?
                .trimmingCharacters(in: .whitespacesAndNewlines), !excerpt.isEmpty else { return nil }
            return TurnPresence.lockScreenText(AtlasMarkdown.plainText(excerpt), limit: 140)
        default:
            return nil
        }
    }
}

enum TurnPresenceNotificationA11ySpoken {
    static func spoken(title: String, subtitle: String, body: String?) -> String {
        guard let body, !body.isEmpty else { return "\(title), \(subtitle)" }
        return "\(title), \(subtitle). \(body)"
    }
}

enum TurnPresenceNotificationA11yTerminal {
    /// Só fases terminais publicadas pelo contrato de presença.
    static func isTerminal(_ presence: AtlasExecutionPresence) -> Bool {
        presence.timing == .finished
            && (presence.phaseTitle == "Concluído" || presence.phaseTitle == "Falhou")
    }

    static func title(from presence: AtlasExecutionPresence) -> String {
        presence.phaseTitle
    }
}

@MainActor
extension TurnPresence {
    func notifyIfAway(_ entry: Entry, model: ConversationModel,
                      finalPresence: AtlasExecutionPresence?, traceId: TraceID?) {
        guard UIApplication.shared.applicationState != .active else { return }
        guard let presence = finalPresence,
              TurnPresenceNotificationA11y.isTerminal(presence) else { return }

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
        content.title = TurnPresenceNotificationA11yTerminal.title(from: presence)
        content.subtitle = Self.lockScreenText(entry.threadTitle, limit: 48)
        if let body = TurnPresenceNotificationA11yBody.body(
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
        let collapsed = value
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard collapsed.count > limit else { return collapsed }
        return String(collapsed.prefix(max(0, limit - 1))) + "…"
    }
}

@MainActor
extension TurnPresence {
    /// Pede permissão no PRIMEIRO turno concluído (momento de valor real),
    /// nunca no launch — UX de permissão digna.
    func requestPermissionOnce() async {
        guard !askedPermission else { return }
        askedPermission = true
        // `await` de propósito: sem esperar o veredito, a notificação sai antes
        // de existir permissão e o iOS a descarta calada.
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }
}

// Notificação local quando uma resposta conclui com o app fora da tela.


// Cycle 043 fuse → LiveActivityRemoteBridge.swift

#if canImport(ActivityKit)

/// Transporte APNs de uma Live Activity já iniciada na tela local.
///
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


// Cycle 044 fuse → AtlasNativeSnapshotWriter.swift

/// Escreve o SD-1 no App Group. O writer só agrega dados já vistos pelos models;
/// fonte ausente vira seção ausente, nunca número ou saúde inventados.
@MainActor
final class AtlasNativeSnapshotWriter {
    static let shared = AtlasNativeSnapshotWriter()

    private var latestFleet: AtlasNativeSnapshot.Fleet?
    private var latestWeek: AtlasNativeSnapshot.Week?
    private var latestQueuedCount: Int?
    private var latestRemoteLiveSessions: [LiveSessionSnapshot] = []
    private let store: AtlasNativeSnapshotStore?

    private init() {
        if let file = AtlasNativeSnapshotStore.appGroupFileURL() {
            store = AtlasNativeSnapshotStore(fileURL: file)
        } else {
            store = nil
        }
    }

    func recordAutonomos(_ model: AutonomosModel) {
        latestFleet = Self.fleet(from: model)
        Task { await write() }
    }

    func recordCodeWeek(_ week: AtlasCodeWeek?) {
        latestWeek = week.map {
            AtlasNativeSnapshot.Week(
                window: $0.window,
                commits: $0.commits,
                heals: $0.heals,
                prevented: $0.prevented
            )
        }
        Task { await write() }
    }

    func recordQueuedCount(_ count: Int) {
        latestQueuedCount = max(0, count)
        Task { await write() }
    }

    func recordRemoteLiveSessions(_ sessions: [LiveSessionSnapshot]) {
        latestRemoteLiveSessions = sessions
        Task { await write() }
    }

    func write() async {
        guard let store else { return }
        let snapshot = AtlasNativeSnapshot(
            generatedAt: Date(),
            liveSessions: Self.liveSessions(from: TurnPresence.shared.liveSessions + latestRemoteLiveSessions),
            fleet: latestFleet,
            week: latestWeek,
            queuedCount: latestQueuedCount
        )
        try? await store.save(snapshot)
        // Widgets só refrescam se o App Group estiver provisionado; reload é barato.
        WidgetCenter.shared.reloadAllTimelines()
    }
}

extension AtlasNativeSnapshotWriter {
    static func fleet(from model: AutonomosModel) -> AtlasNativeSnapshot.Fleet? {
        guard model.taskHealth != nil || model.delivered != nil else { return nil }
        let health = model.taskHealth
        let delivery = model.delivered?.delivered.max {
            AtlasTime.ms($0.recordedAt) < AtlasTime.ms($1.recordedAt)
        }
        let incident: AtlasNativeSnapshot.Fleet.Incident?
        if health?.incidents.present == true {
            incident = AtlasNativeSnapshot.Fleet.Incident(
                present: true,
                flags: health?.incidents.flags ?? [],
                recommendedAction: health?.operating.recommendedAction
            )
        } else {
            incident = nil
        }
        return AtlasNativeSnapshot.Fleet(
            scannedAt: health?.observedAt,
            incident: incident,
            lastDelivery: delivery.map {
                AtlasNativeSnapshot.Fleet.LastDelivery(
                    title: "ciclo \($0.cycleIndex) · \($0.outcome)",
                    mergeHash: $0.mergeHash,
                    at: $0.recordedAt
                )
            }
        )
    }

    static func iso(_ date: Date) -> String {
        date.formatted(.iso8601.year().month().day().time(includingFractionalSeconds: false).timeZone(separator: .omitted))
    }
}

extension AtlasNativeSnapshotWriter {
    static func liveSessions(from sessions: [LiveSessionSnapshot]) -> [AtlasNativeSnapshot.LiveSession]? {
        let projected = sessions.map { session in
            AtlasNativeSnapshot.LiveSession(
                title: session.title,
                phaseTitle: session.phaseTitle,
                timing: timing(from: session.timing),
                elapsedActiveMs: session.elapsedActiveMs,
                runningSince: session.runningSince.map(iso)
            )
        }
        return projected.isEmpty ? [] : projected
    }

    static func timing(from timing: AtlasExecutionPresence.Timing) -> AtlasNativeSnapshot.LiveSession.Timing {
        switch timing {
        case .running: return .running
        case .paused: return .paused
        case .finished: return .finished
        }
    }
}
