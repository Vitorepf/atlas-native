import SwiftUI
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
// Notificações locais → TurnPresence+Notifications.swift (+A11y).
// LiveSessionSnapshot/publish → TurnPresence+LiveSessions.swift.
// tick/lastPresence → TurnPresence+Tick.swift.
// Entry → TurnPresence+Entry.swift.

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

    /// Model desalocado (conversa fechada): encerra a activity órfã com honestidade.
    func cleanup(_ id: ObjectIdentifier) {
        guard let entry = entries.removeValue(forKey: id) else { return }
        if entry.ongoing { finishActivity(entry, presence: nil, phaseOverride: "sessão encerrada") }
        broadcastCount()
        syncRunning()
    }
}
