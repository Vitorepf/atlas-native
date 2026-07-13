import SwiftUI
import UserNotifications
#if canImport(ActivityKit)
import ActivityKit
#endif

// A presença do turno FORA do app — tela bloqueada e Dynamic Island (paridade
// Cursor): Live Activity enquanto o Atlas trabalha, notificação local quando a
// resposta conclui com o app fora da tela. 100% casca: observa o model por
// withObservationTracking (zero edição na lógica), fala só com frameworks de
// apresentação do sistema (ActivityKit/UserNotifications — sem rede/JSON/
// storage). Limite honesto: sem push do servidor (fase APNs, §5 C8), a
// atualização em background vive da janela de execução do iOS (~30s) — cobre
// o turno típico; turnos longos concluem a notificação quando o app volta.
@MainActor
final class TurnPresence {
    static let shared = TurnPresence()
    private init() {}

    private weak var model: ConversationModel?
    private var threadTitle = "Atlas"
    private var wasSending = false
    private var startedAt = Date()
    private var askedPermission = false
    #if canImport(ActivityKit)
    private var activity: Activity<AtlasTurnAttributes>?
    #endif

    /// Chamado pela ConversationView no onAppear — troca o alvo observado.
    func watch(_ model: ConversationModel, threadTitle: String) {
        self.model = model
        self.threadTitle = threadTitle
        observe()
    }

    private func observe() {
        guard let model else { return }
        withObservationTracking {
            _ = model.isSending
            _ = model.bubbles.last?.currentActivity?.title
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.tick()
                self?.observe()   // re-arma (tracking é one-shot)
            }
        }
    }

    private func tick() {
        guard let model else { return }
        let sending = model.isSending
        let phase = model.bubbles.last?.currentActivity?.title ?? "pensando…"

        if sending && !wasSending {
            startedAt = Date()
            startActivity(phase: phase)
        } else if sending {
            updateActivity(phase: phase)
        } else if wasSending {
            finishActivity()
            notifyIfAway()
            requestPermissionOnce()
        }
        wasSending = sending
    }

    // MARK: - Notificação local (tela bloqueada)

    private func notifyIfAway() {
        guard UIApplication.shared.applicationState != .active else { return }
        guard let model else { return }
        let excerpt = model.bubbles.last(where: { $0.role == "assistant" })?.text ?? ""
        let content = UNMutableNotificationContent()
        content.title = "Atlas respondeu"
        content.subtitle = threadTitle
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

    // MARK: - Live Activity (lock screen + Dynamic Island)

    private func startActivity(phase: String) {
        #if canImport(ActivityKit)
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let state = AtlasTurnAttributes.ContentState(phaseTitle: phase, startedAt: startedAt, finished: false)
        activity = try? Activity.request(
            attributes: AtlasTurnAttributes(threadTitle: threadTitle),
            content: .init(state: state, staleDate: nil))
        #endif
    }

    // Activity<T> não é Sendable no Swift 6 — nunca atravessa Task. Dentro da
    // Task, enumeramos as activities ESTATICAMENTE (nada cruza a região).
    private func updateActivity(phase: String) {
        #if canImport(ActivityKit)
        guard activity != nil else { return }
        let state = AtlasTurnAttributes.ContentState(phaseTitle: phase, startedAt: startedAt, finished: false)
        Task { @MainActor in
            for a in Activity<AtlasTurnAttributes>.activities {
                await a.update(.init(state: state, staleDate: nil))
            }
        }
        #endif
    }

    private func finishActivity() {
        #if canImport(ActivityKit)
        guard activity != nil else { return }
        let state = AtlasTurnAttributes.ContentState(phaseTitle: "resposta pronta", startedAt: startedAt, finished: true)
        Task { @MainActor in
            for a in Activity<AtlasTurnAttributes>.activities {
                await a.end(.init(state: state, staleDate: nil),
                            dismissalPolicy: .after(.now + 4))
            }
        }
        self.activity = nil
        #endif
    }
}
