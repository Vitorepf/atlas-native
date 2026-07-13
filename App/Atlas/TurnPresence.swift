import SwiftUI
import UserNotifications
#if canImport(ActivityKit)
import ActivityKit
#endif

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
@MainActor
final class TurnPresence {
    static let shared = TurnPresence()
    private init() {}

    /// Um turno observado. Classe (não struct) para `weak model` no registro.
    private final class Entry {
        weak var model: ConversationModel?
        var threadTitle: String
        let key: String            // liga model ↔ activity (attributes.threadKey)
        var wasSending = false
        var startedAt = Date()
        init(model: ConversationModel, threadTitle: String) {
            self.model = model
            self.threadTitle = threadTitle
            self.key = UUID().uuidString
        }
    }

    private var entries: [ObjectIdentifier: Entry] = [:]
    private var askedPermission = false

    /// Quantas sessões estão executando agora (a verdade do contador).
    private var activeCount: Int { entries.values.filter { $0.wasSending }.count }

    /// Chamado pela ConversationView no onAppear — registra/atualiza o alvo.
    /// Cada conversa aberta é observada de forma independente (multi-sessão).
    func watch(_ model: ConversationModel, threadTitle: String) {
        let id = ObjectIdentifier(model)
        if let existing = entries[id] {
            existing.threadTitle = threadTitle
            return
        }
        let entry = Entry(model: model, threadTitle: threadTitle)
        entries[id] = entry
        observe(id)
    }

    private func observe(_ id: ObjectIdentifier) {
        guard let entry = entries[id], let model = entry.model else {
            cleanup(id); return
        }
        withObservationTracking {
            _ = model.isSending
            _ = model.bubbles.last?.currentActivity?.title
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.tick(id)
                self?.observe(id)   // re-arma (tracking é one-shot)
            }
        }
    }

    private func tick(_ id: ObjectIdentifier) {
        guard let entry = entries[id] else { return }
        guard let model = entry.model else { cleanup(id); return }
        let sending = model.isSending
        let phase = model.bubbles.last?.currentActivity?.title ?? "pensando…"

        if sending && !entry.wasSending {
            entry.startedAt = Date()
            entry.wasSending = true
            startActivity(entry)
            broadcastCount()                 // as outras ganham o "× N"
        } else if sending {
            updateActivity(entry, phase: phase)
        } else if entry.wasSending {
            entry.wasSending = false
            finishActivity(entry)            // "resposta pronta ✓", encerra em 4s
            broadcastCount()                 // as vivas atualizam o contador
            notifyIfAway(entry, model: model)
            requestPermissionOnce()
        }
    }

    /// Model desalocado (conversa fechada): encerra a activity órfã com honestidade.
    private func cleanup(_ id: ObjectIdentifier) {
        guard let entry = entries.removeValue(forKey: id) else { return }
        if entry.wasSending { finishActivity(entry, phase: "sessão encerrada") }
        broadcastCount()
    }

    // MARK: - Notificação local (tela bloqueada)

    private func notifyIfAway(_ entry: Entry, model: ConversationModel) {
        guard UIApplication.shared.applicationState != .active else { return }
        let excerpt = model.bubbles.last(where: { $0.role == "assistant" })?.text ?? ""
        let content = UNMutableNotificationContent()
        content.title = "Atlas respondeu"
        content.subtitle = entry.threadTitle
        content.body = String(excerpt.prefix(140))
        content.sound = .default
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
    }

    /// Pede permissão no PRIMEIRO turno concluído (momento de valor real),
    /// nunca no launch — UX de permissão digna.
    private func requestPermissionOnce() {
        guard !askedPermission else { return }
        askedPermission = true
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    // MARK: - Live Activities (uma por sessão; contador compartilhado)
    // Activity<T> não é Sendable no Swift 6 — nunca atravessa Task. Dentro das
    // Tasks, enumeramos ESTATICAMENTE filtrando por attributes.threadKey.

    private func startActivity(_ entry: Entry) {
        #if canImport(ActivityKit)
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let state = AtlasTurnAttributes.ContentState(
            phaseTitle: "pensando…", startedAt: entry.startedAt,
            finished: false, activeSessions: max(1, activeCount))
        _ = try? Activity.request(
            attributes: AtlasTurnAttributes(threadTitle: entry.threadTitle, threadKey: entry.key),
            content: .init(state: state, staleDate: nil))
        #endif
    }

    private func updateActivity(_ entry: Entry, phase: String) {
        #if canImport(ActivityKit)
        let state = AtlasTurnAttributes.ContentState(
            phaseTitle: phase, startedAt: entry.startedAt,
            finished: false, activeSessions: max(1, activeCount))
        let key = entry.key
        Task { @MainActor in
            for a in Activity<AtlasTurnAttributes>.activities where a.attributes.threadKey == key {
                await a.update(.init(state: state, staleDate: nil))
            }
        }
        #endif
    }

    private func finishActivity(_ entry: Entry, phase: String = "resposta pronta") {
        #if canImport(ActivityKit)
        let state = AtlasTurnAttributes.ContentState(
            phaseTitle: phase, startedAt: entry.startedAt,
            finished: true, activeSessions: max(0, activeCount))
        let key = entry.key
        Task { @MainActor in
            for a in Activity<AtlasTurnAttributes>.activities where a.attributes.threadKey == key {
                await a.end(.init(state: state, staleDate: nil),
                            dismissalPolicy: .after(.now + 4))
            }
        }
        #endif
    }

    /// Propaga o contador novo para TODAS as activities vivas, preservando a
    /// fase e o timer de cada uma (lê o estado atual e só troca o contador).
    private func broadcastCount() {
        #if canImport(ActivityKit)
        let count = activeCount
        Task { @MainActor in
            for a in Activity<AtlasTurnAttributes>.activities {
                let s = a.content.state
                guard !s.finished, s.activeSessions != max(1, count) else { continue }
                let next = AtlasTurnAttributes.ContentState(
                    phaseTitle: s.phaseTitle, startedAt: s.startedAt,
                    finished: false, activeSessions: max(1, count))
                await a.update(.init(state: next, staleDate: nil))
            }
        }
        #endif
    }
}
