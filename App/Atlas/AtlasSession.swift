import SwiftUI
import Network
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
    private static let auditModeKey = "atlas.auditMode.enabled"

    var phase: LoadPhase = .idle
    var failureKind: AtlasNetworkFailureKind?
    var threads: [AtlasAiThread] = []
    private(set) var remoteLiveSessions: [LiveSessionSnapshot] = []
    var auditModeEnabled: Bool {
        didSet { UserDefaults.standard.set(auditModeEnabled, forKey: Self.auditModeKey) }
    }

    let host: String
    let hasToken: Bool
    let client: AtlasClient   // compartilhado com a ConversationModel
    /// Área 24/7 independente de conversa. Root/Fable pode navegar para ela
    /// sem usar threads como fonte falsa de estado.
    let autonomos: AutonomosModel
    let arena: ArenaModel
    @ObservationIgnored var liveSessionsPollingTask: Task<Void, Never>?
    @ObservationIgnored private let pathMonitor = NWPathMonitor()
    @ObservationIgnored private let pathMonitorQueue = DispatchQueue(label: "atlas.native.path-monitor")
    @ObservationIgnored private var sawPathDown = false
    @ObservationIgnored private var reconnectAfterRestoreArmed = true

    init() {
        let info = Bundle.main.infoDictionary ?? [:]
        let host = (info["ATLAS_HOST"] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? "127.0.0.1"
        let port = Int((info["ATLAS_PORT"] as? String) ?? "3737") ?? 3737
        let token = AtlasTokenStore.resolve(configuredToken: (info["ATLAS_TOKEN"] as? String) ?? "")
        self.host = host
        self.hasToken = !token.isEmpty
        let client = AtlasClient(config: AtlasConfig(host: host, port: port, token: token))
        self.client = client
        self.autonomos = AutonomosModel(client: client)
        self.arena = ArenaModel(client: client)
        self.auditModeEnabled = UserDefaults.standard.bool(forKey: Self.auditModeKey)
        startPathMonitor()
    }

    deinit {
        pathMonitor.cancel()
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

    private func startPathMonitor() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self else { return }
                await self.client.setNetworkPathCost(.init(
                    isExpensive: path.isExpensive,
                    isConstrained: path.isConstrained
                ))
                if path.status == .satisfied {
                    if sawPathDown, reconnectAfterRestoreArmed, case .failed = phase {
                        reconnectAfterRestoreArmed = false
                        await loadThreads()
                    }
                    sawPathDown = false
                } else {
                    sawPathDown = true
                    reconnectAfterRestoreArmed = true
                }
            }
        }
        pathMonitor.start(queue: pathMonitorQueue)
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
