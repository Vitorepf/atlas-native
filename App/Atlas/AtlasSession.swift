import SwiftUI
import AtlasCore

// A ponte entre o AtlasCore (lógica/rede pura) e a UI. @Observable + @MainActor:
// o estado vive na main thread, as chamadas de rede vão pro actor AtlasClient.
// Host/porta/token vêm do Info.plist (populados pelo Config.xcconfig / Secrets),
// espelhando como o app RN lê `expo extra.atlas`.
@MainActor
@Observable
final class AtlasSession {
    static let rhythm = AtlasDayRhythm()
    private static let nightlyProposalMuteKey = "atlas.nightlyProposal.mutedUntil"

    var phase: LoadPhase = .idle
    var failureKind: AtlasNetworkFailureKind?
    var threads: [AtlasAiThread] = []
    private(set) var remoteLiveSessions: [LiveSessionSnapshot] = []

    let host: String
    let hasToken: Bool
    let client: AtlasClient   // compartilhado com a ConversationModel
    /// Área 24/7 independente de conversa. Root/Fable pode navegar para ela
    /// sem usar threads como fonte falsa de estado.
    let autonomos: AutonomosModel
    let arena: ArenaModel
    @ObservationIgnored private var liveSessionsPollingTask: Task<Void, Never>?

    init() {
        let info = Bundle.main.infoDictionary ?? [:]
        let host = (info["ATLAS_HOST"] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? "127.0.0.1"
        let port = Int((info["ATLAS_PORT"] as? String) ?? "3737") ?? 3737
        let token = (info["ATLAS_TOKEN"] as? String) ?? ""
        self.host = host
        self.hasToken = !token.isEmpty
        let client = AtlasClient(config: AtlasConfig(host: host, port: port, token: token))
        self.client = client
        self.autonomos = AutonomosModel(client: client)
        self.arena = ArenaModel(client: client)
    }

    func loadThreads() async {
        phase = .loading
        failureKind = nil
        do {
            let response = try await client.listAiThreads(light: true, limit: 100)
            threads = response.threads
            phase = .loaded
            Task { await Self.rhythm.recordActivity(workspace: nil) }
        } catch {
            failureKind = atlasNetworkFailureKind(for: error)
            phase = .failed(String(describing: error))
        }
    }

    func setLiveSessionsPollingActive(_ active: Bool) {
        guard active, hasToken else {
            liveSessionsPollingTask?.cancel()
            liveSessionsPollingTask = nil
            remoteLiveSessions = []
            return
        }
        guard liveSessionsPollingTask == nil else { return }
        liveSessionsPollingTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                await self?.refreshRemoteLiveSessions()
                do {
                    try await Task.sleep(nanoseconds: 30_000_000_000)
                } catch {
                    break
                }
            }
        }
    }

    private func refreshRemoteLiveSessions() async {
        do {
            let response = try await client.getAiSessionsLive(installation: AtlasInstallationIdentity.id)
            remoteLiveSessions = response.sessions.enumerated().map { index, session in
                LiveSessionSnapshot(remote: session, index: index)
            }
        } catch {
            remoteLiveSessions = []
        }
    }

    static func nightlyProposalMutedUntil(now: Date = .init()) -> Date? {
        guard let until = UserDefaults.standard.object(forKey: nightlyProposalMuteKey) as? Date else {
            return nil
        }
        if until > now { return until }
        UserDefaults.standard.removeObject(forKey: nightlyProposalMuteKey)
        return nil
    }

    @discardableResult
    static func muteNightlyProposal(days: Int, now: Date = .init()) -> Date {
        let days = max(1, days)
        let until = Calendar.current.date(byAdding: .day, value: days, to: now)
            ?? now.addingTimeInterval(Double(days) * 86_400)
        UserDefaults.standard.set(until, forKey: nightlyProposalMuteKey)
        return until
    }

    static func clearExpiredNightlyProposalMute(now: Date = .init()) -> Date? {
        nightlyProposalMutedUntil(now: now)
    }

    // MARK: - Workspaces (agrupa as threads pelo repo real — campo `workspace`)

    /// Workspaces derivados do campo `workspace` das threads (o caminho do repo),
    /// agrupados por nome de pasta. Espelha o "repos" do Cursor, com dado real.
    var workspaces: [Workspace] {
        var groups: [String: (name: String, count: Int)] = [:]
        for t in threads {
            guard let w = t.workspace, !w.isEmpty else { continue }
            let base = (w as NSString).lastPathComponent
            let key = base.lowercased()
            var g = groups[key] ?? (name: base, count: 0)
            g.count += 1
            groups[key] = g
        }
        return groups
            .map { Workspace(id: $0.key, name: $0.value.name, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    /// Caminho completo do workspace (primeira thread do grupo) — pro payload
    /// workspace_path do create. `nil` se a chave não existir.
    func workspaceFullPath(forKey key: String) -> String? {
        threads.first {
            guard let w = $0.workspace, !w.isEmpty else { return false }
            return (w as NSString).lastPathComponent.lowercased() == key
        }?.workspace
    }

    /// Threads de um workspace (por chave = nome de pasta minúsculo). `nil` = todas.
    func threads(inWorkspace key: String?) -> [AtlasAiThread] {
        guard let key else { return threads }
        return threads.filter {
            guard let w = $0.workspace, !w.isEmpty else { return false }
            return (w as NSString).lastPathComponent.lowercased() == key
        }
    }
}

private extension LiveSessionSnapshot {
    init(remote session: AtlasAiLiveSession, index: Int) {
        let threadId = session.threadId
        self.init(
            id: threadId.map { "remote-thread:\($0.rawValue)" } ?? "remote-session:\(index)",
            threadId: threadId,
            title: session.title?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty ?? "Sessão Atlas",
            phaseTitle: session.phaseTitle?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty ?? "Executando",
            timing: session.timing.presenceTiming,
            elapsedActiveMs: session.elapsedActiveMs,
            runningSince: session.runningSinceDate,
            pauseTimestamp: nil,
            startedAt: .now,
            isRemote: true
        )
    }
}

private extension Optional where Wrapped == AtlasAiLiveSessionTiming {
    var presenceTiming: AtlasExecutionPresence.Timing {
        switch self {
        case .running, nil: return .running
        case .paused: return .paused
        case .finished: return .finished
        }
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}

struct Workspace: Identifiable, Hashable {
    let id: String     // chave = nome de pasta minúsculo
    let name: String   // exibição
    let count: Int
}

// Área/modo de uma conversa. Heurística por surface + metadata (o dado de modo é
// esparso hoje; conforme o servidor popular current_mode/routing_domain, afina).
enum AtlasArea: String, CaseIterable, Identifiable {
    case tudo, operacional, autonomos, programacao
    var id: String { rawValue }
    var label: String {
        switch self {
        case .tudo: return "Tudo"
        case .operacional: return "Operacional"
        case .autonomos: return "Autônomos"
        case .programacao: return "Programação"
        }
    }

    static func of(_ t: AtlasAiThread) -> AtlasArea {
        let surface = t.surface.lowercased()
        let mode = (t.metadata?["current_mode"]?.stringValue
            ?? t.metadata?["atlas_mode"]?.stringValue
            ?? t.metadata?["workflow_mode"]?.stringValue ?? "").lowercased()
        let domain = (t.metadata?["routing_domain"]?.stringValue ?? "").lowercased()
        if surface.contains("code") || domain.contains("eng") || domain.contains("prog") || mode.contains("program") {
            return .programacao
        }
        if mode.contains("auto") || mode.contains("loop") || (t.metadata?["awis_automation"]?.boolValue ?? false) {
            return .autonomos
        }
        return .operacional
    }
}
