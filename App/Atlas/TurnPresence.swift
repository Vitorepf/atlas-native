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
// ActivityKit → +LiveActivity · Notificações → +Notifications
// LiveSessions → +LiveSessions · tick → +Tick · Entry → +Entry · Watch → +Watch

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
