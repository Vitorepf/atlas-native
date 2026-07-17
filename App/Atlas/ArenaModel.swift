import Foundation
import Observation
import AtlasCore

@MainActor
@Observable
final class ArenaModel {
    let client: AtlasClient

    var phase: LoadPhase = .idle
    var composite: AtlasArenaComposite?
    var scoreboard: AtlasArenaScoreboard?
    var capabilities: AtlasArenaCapabilities?
    var liveRuns: AtlasArenaLiveRuns?
    var lastStartReceipt: AtlasArenaStartReceipt?
    var controlError: String?
    /// Tipo de falha de rede (espelha ConversationModel) — casca usa AtlasFailureCopy.
    private(set) var loadFailureKind: AtlasNetworkFailureKind?
    /// 404 / domínio arena ausente — copy própria, não inventa scores.
    private(set) var isDomainUnavailable = false
    private(set) var lastLoadedAt: Date?
    var visible = false
    var livePollingTask: Task<Void, Never>?

    /// Copy canónica quando o servidor ainda não publica medição (spec §E).
    static let domainUnavailableCopy = "medição ainda não publicada pelo servidor"

    init(client: AtlasClient) {
        self.client = client
    }

    var preferredEngine: String? {
        composite?.engines.first?.engine
            ?? scoreboard?.suites.lazy.flatMap(\.engines).first?.engine
    }

    var regressionException: String? {
        for suite in scoreboard?.suites ?? [] {
            guard let engine = suite.engines.first(where: \.regressed),
                  let delta = engine.delta else { continue }
            return "\(suite.suite) · \(engine.engine) regrediu \(ArenaFormat.signed(delta))"
        }
        return nil
    }

    var snapshotAgeText: String? {
        guard let lastLoadedAt else { return nil }
        let seconds = max(0, Int(Date().timeIntervalSince(lastLoadedAt)))
        switch seconds {
        case ..<60: return "agora"
        case ..<3600: return "há \(seconds / 60)min"
        default: return "há \(seconds / 3600)h"
        }
    }

    func load() async {
        phase = .loading
        controlError = nil
        loadFailureKind = nil
        isDomainUnavailable = false
        do {
            async let compositeRequest = client.getArenaComposite()
            async let scoreboardRequest = client.getArenaScoreboard()
            let (nextComposite, nextScoreboard) = try await (compositeRequest, scoreboardRequest)
            composite = nextComposite
            scoreboard = nextScoreboard
            if let engine = nextComposite.engines.first?.engine {
                capabilities = try? await client.getArenaCapabilities(engine: engine)
            }
            liveRuns = try? await client.getArenaLiveRuns()
            lastLoadedAt = Date()
            phase = .loaded
            updateLivePolling()
        } catch {
            let domainMissing = Self.isDomainUnavailableError(error)
            isDomainUnavailable = domainMissing
            loadFailureKind = domainMissing ? nil : atlasNetworkFailureKind(for: error)
            phase = .failed(Self.publicMessage(error))
        }
    }

    func setVisible(_ isVisible: Bool) {
        visible = isVisible
        updateLivePolling()
    }
}
