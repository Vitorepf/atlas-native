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
    /// Capacidades por motor (goal 3: perfil de habilidades de TODOS os
    /// motores, não só o primeiro). Chave = engine id público.
    var capabilitiesByEngine: [String: AtlasArenaCapabilities] = [:]
    /// Motor escolhido no hero de capacidades (nil = primeiro do índice).
    var capabilitiesEngineSelection: String?
    var liveRuns: AtlasArenaLiveRuns?
    /// Catálogo B6 de motores rodáveis — estreia de motor novo pelo app.
    var engineCatalog: AtlasArenaEngines?
    var lastStartReceipt: AtlasArenaStartReceipt?
    /// Agregado do último start multi-motor (goal 1) — soma dos recibos B5.
    var lastStartEnginesCount = 0
    var lastStartRunsPlannedTotal = 0
    var controlError: String?
    /// Tipo de falha de rede (espelha ConversationModel) — casca usa AtlasFailureCopy.
    private(set) var loadFailureKind: AtlasNetworkFailureKind?
    /// 404 / domínio arena ausente — copy própria, não inventa scores.
    private(set) var isDomainUnavailable = false
    private(set) var lastLoadedAt: Date?

    /// Único ponto de escrita do carimbo (peels em outros arquivos usam isto).
    func markLoaded() { lastLoadedAt = Date() }
    var visible = false
    var livePollingTask: Task<Void, Never>?

    /// Copy canónica quando o servidor ainda não publica medição (spec §E).
    static let domainUnavailableCopy = "medição ainda não publicada pelo servidor"

    init(client: AtlasClient) {
        self.client = client
    }

    /// Motores com perfil de capacidades disponível, na ordem do índice.
    var capabilityEngineOptions: [String] {
        (composite?.engines.map(\.engine) ?? []).filter { capabilitiesByEngine[$0] != nil }
    }

    /// Capacidades do motor escolhido no hero (fallback: primeiro do índice).
    var selectedCapabilities: AtlasArenaCapabilities? {
        if let selection = capabilitiesEngineSelection, let chosen = capabilitiesByEngine[selection] {
            return chosen
        }
        return capabilityEngineOptions.first.flatMap { capabilitiesByEngine[$0] } ?? capabilities
    }

    var preferredEngine: String? {
        composite?.engines.first?.engine
            ?? scoreboard?.suites.lazy.flatMap(\.engines).first?.engine
    }

    var regressionException: String? {
        for suite in scoreboard?.suites ?? [] {
            guard let engine = suite.engines.first(where: \.regressed),
                  let delta = engine.delta else { continue }
            // O fato lidera; os nomes vêm depois ("Verboo regrediu" lia como
            // português quebrado quando o braço tem nome próprio).
            return "regrediu \(ArenaFormat.signed(delta)) · \(ArenaDisplay.suite(suite.suite)) · \(ArenaDisplay.engine(engine.engine))"
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
            // Capacidades ANTES de publicar o composite: @Observable re-renderiza
            // na 1ª atribuição, e o hero não pode nascer dizendo "não medida"
            // enquanto o fetch ainda está em voo (estado atômico, nunca meia-tela).
            var byEngine: [String: AtlasArenaCapabilities] = [:]
            for engine in nextComposite.engines.map(\.engine) {
                byEngine[engine] = try? await client.getArenaCapabilities(engine: engine)
            }
            capabilitiesByEngine = byEngine
            capabilities = nextComposite.engines.first.flatMap { byEngine[$0.engine] }
            composite = nextComposite
            scoreboard = nextScoreboard
            liveRuns = try? await client.getArenaLiveRuns()
            engineCatalog = try? await client.getArenaEngines()
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
