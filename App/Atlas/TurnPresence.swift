import SwiftUI
import UserNotifications
import AtlasCore   // só tipos (AtlasExecutionPresence) — regra 4 da fronteira

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
// ActivityKit start/update/finish → TurnPresence+LiveActivity.swift.
/// Snapshot de uma sessão viva observada neste processo — a home lê isto
/// para virar cockpit (V1). Zero rede; só o que o TurnPresence já sabe.
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
    /// só quando este array não está vazio (lei V1.1).
    private(set) var liveSessions: [LiveSessionSnapshot] = []

    /// Um turno observado. Classe (não struct) para `weak model` no registro.
    /// Visível no módulo para `TurnPresence+LiveActivity`.
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

    @ObservationIgnored private var entries: [ObjectIdentifier: Entry] = [:]
    @ObservationIgnored private var askedPermission = false

    private func syncRunning() {
        runningTitles = Set(entries.values.filter { $0.ongoing }.map { $0.threadTitle })
        publishLiveSessions()
        Task { await AtlasNativeSnapshotWriter.shared.write() }
    }

    /// Reconstrói `liveSessions` a partir das entries ongoing. Dedup por
    /// traceId; conversa nova sem thread canônica fica sem navegação.
    private func publishLiveSessions() {
        var byTrace: [String: LiveSessionSnapshot] = [:]
        for entry in entries.values where entry.ongoing {
            guard let model = entry.model,
                  let presence = model.currentExecutionPresence,
                  let trace = model.currentExecutionPresenceTraceId else { continue }
            var phase = presence.phaseTitle
            if presence.timing == .running,
               let prog = model.bubbles.last(where: { $0.traceId == trace })?.executionProgress {
                phase = "\(prog.current)/\(prog.total) · \(prog.title)"
            }
            let snap = LiveSessionSnapshot(
                id: trace.rawValue,
                threadId: entry.threadId ?? model.threadId,
                title: entry.threadTitle,
                phaseTitle: phase,
                timing: presence.timing,
                elapsedActiveMs: presence.elapsedActiveMilliseconds,
                runningSince: presence.runningSince,
                pauseTimestamp: presence.pauseTimestamp,
                startedAt: entry.startedAt,
                isRemote: false
            )
            byTrace[snap.id] = snap
        }
        liveSessions = byTrace.values.sorted { $0.startedAt < $1.startedAt }
    }

    /// Quantas sessões vivem agora (running + paused — a verdade do contador).
    /// Visível no módulo para `TurnPresence+LiveActivity`.
    var activeCount: Int { entries.values.filter { $0.ongoing }.count }

    /// Chamado pela ConversationView no onAppear — registra/atualiza o alvo.
    /// Cada conversa aberta é observada de forma independente (multi-sessão).
    /// `threadId` nil = conversa nova local (linha viva sem navegação até o
    /// servidor confirmar a thread canônica).
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

    private func observe(_ id: ObjectIdentifier) {
        guard let entry = entries[id], let model = entry.model else {
            cleanup(id); return
        }
        withObservationTracking {
            // C14: o seam é a PRESENÇA tipada, nunca isSending/status cru.
            _ = model.currentExecutionPresenceTraceId
            _ = model.currentExecutionPresence?.phaseTitle
            _ = model.currentExecutionPresence?.timing
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
        let presence = model.currentExecutionPresence
        let trace = model.currentExecutionPresenceTraceId

        if let p = presence, let trace {
            // C10: rodando com checkpoint REAL do plano, a fase da Lock
            // Screen é "N/M · etapa"; sem plano, a fase pública da presença.
            var phase: String? = nil
            if p.timing == .running,
               let prog = model.bubbles.last(where: { $0.traceId == trace })?.executionProgress {
                phase = "\(prog.current)/\(prog.total) · \(prog.title)"
            }
            // Sessão viva (running OU paused): a MESMA Activity atravessa
            // stream fechado, pausa aguardando decisão e reconexão.
            if entry.activityKey != nil && entry.activityKey != trace {
                finishActivity(entry, presence: lastPresence(model, key: entry.activityKey))
            }
            if !entry.ongoing || !entry.activityStarted {
                if !entry.ongoing { entry.startedAt = Date() }   // base legada
                entry.ongoing = true
                startActivity(entry, traceId: trace, presence: p, phaseOverride: phase)
                broadcastCount()
                syncRunning()
            } else {
                updateActivity(entry, presence: p, phaseOverride: phase)
            }
        } else if entry.ongoing {
            // Fase pública terminal (Concluído/Falhou) ou fim legado — nunca
            // "porque isSending virou falso": a presença é quem decide.
            entry.ongoing = false
            let final = lastPresence(model, key: entry.activityKey)
            finishActivity(entry, presence: final)
            broadcastCount()
            if UIApplication.shared.applicationState == .active, !entry.visible {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
            // A permissão PRIMEIRO, e esperando o veredito: pedir depois de
            // notificar fazia a primeira notificação da vida do app ser sempre
            // descartada em silêncio — justamente a que prova ao operador que a
            // presença funciona. Continua sendo no primeiro turno concluído (o
            // momento de valor real), nunca no launch.
            Task { @MainActor in
                await requestPermissionOnce()
                notifyIfAway(entry, model: model, finalPresence: final)
            }
            syncRunning()
        }
    }

    /// A presença final da bolha dona da Activity (fase "Concluído"/"Falhou").
    private func lastPresence(_ model: ConversationModel, key: TraceID?) -> AtlasExecutionPresence? {
        guard let key else { return nil }
        return model.bubbles.last(where: { $0.traceId == key })?.executionPresence
    }

    /// Model desalocado (conversa fechada): encerra a activity órfã com honestidade.
    private func cleanup(_ id: ObjectIdentifier) {
        guard let entry = entries.removeValue(forKey: id) else { return }
        if entry.ongoing { finishActivity(entry, presence: nil, phaseOverride: "sessão encerrada") }
        broadcastCount()
        syncRunning()
    }

    // MARK: - Notificação local (tela bloqueada)

    /// Avisa SÓ pela fase pública terminal — nunca por isSending virar falso.
    private func notifyIfAway(_ entry: Entry, model: ConversationModel,
                              finalPresence: AtlasExecutionPresence?) {
        guard UIApplication.shared.applicationState != .active else { return }
        let failed = finalPresence?.phaseTitle == "Falhou"
        let excerpt = model.bubbles.last(where: { $0.role == "assistant" })?.text ?? ""
        let content = UNMutableNotificationContent()
        content.title = failed ? "O turno falhou" : "Atlas respondeu"
        content.subtitle = Self.lockScreenText(entry.threadTitle, limit: 48)
        // O texto SEM a sintaxe: este é o mesmo campo que a tela entrega ao
        // parser markdown, e ia cru para a Lock Screen — o operador longe do app
        // lia `**pronto**` e `## Resposta` em vez da resposta.
        content.body = failed ? "Toque para ver o motivo e retomar."
                              : Self.lockScreenText(AtlasMarkdown.plainText(excerpt), limit: 140)
        content.sound = .default
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
    }

    /// Pede permissão no PRIMEIRO turno concluído (momento de valor real),
    /// nunca no launch — UX de permissão digna.
    private func requestPermissionOnce() async {
        guard !askedPermission else { return }
        askedPermission = true
        // `await` de propósito: sem esperar o veredito, a notificação sai antes
        // de existir permissão e o iOS a descarta calada.
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }

    static func lockScreenText(_ value: String, limit: Int) -> String {
        let collapsed = value
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard collapsed.count > limit else { return collapsed }
        return String(collapsed.prefix(max(0, limit - 1))) + "…"
    }
}
