import SwiftUI
import Network
import AtlasCore

// A ponte entre o AtlasCore (lógica/rede pura) e a UI. Nightly: AtlasSession+Nightly.swift
// Workspaces: AtlasSession+Workspaces.swift
@MainActor
@Observable
final class AtlasSession {
    static let rhythm = AtlasDayRhythm()
    static let nightlyProposalMuteKey = "atlas.nightlyProposal.mutedUntil"
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
    let client: AtlasClient
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
}
