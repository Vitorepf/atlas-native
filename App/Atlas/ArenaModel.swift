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
    /// Relatório editorial provider-safe para Resultados, Alertas e detalhes.
    /// Ausente quando o servidor ainda não publicou enterprise/report.json.
    var report: AtlasArenaReport?
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
    /// Recibo idempotente da última solicitação de parada.
    var lastStopReceipt: AtlasArenaStopReceipt?
    /// Plano local exato do último start pedido pelo operador.
    var activePlan: AtlasArenaMeasurementPlan?
    /// Recibos já confirmados do último start, inclusive quando um lote termina
    /// parcialmente. Um erro posterior nunca apaga o que o servidor enfileirou.
    var lastStartReceipts: [AtlasArenaStartReceipt] = []
    /// Evita POST duplicado por toque repetido enquanto um lote está em voo.
    var isStartingRuns = false
    var isStoppingMeasurement = false
    /// Agregado confirmado do último start multi-motor — soma dos recibos B5.
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
#if DEBUG
    /// Cenário determinístico exclusivamente para prova visual no simulador.
    var visualScenarioInstalled = false
#endif

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

    /// Ponto ÚNICO de carga do hero de capacidades — load() e o refresh da
    /// tela passam por aqui (o refresh keep-snapshot deixava o hero órfão:
    /// launch com rede em corrida → capacidades nunca mais carregavam).
    func loadCapabilities(
        for composite: AtlasArenaComposite,
        preserveCurrentOnTotalFailure: Bool = false
    ) async {
        var byEngine: [String: AtlasArenaCapabilities] = [:]
        var successfulFetches = 0
        let engines = composite.engines.map(\.engine)
        let client = client
        await withTaskGroup(of: (String, AtlasArenaCapabilities?, Bool).self) { group in
            for engine in engines {
                group.addTask {
                    do {
                        return (engine, try await client.getArenaCapabilities(engine: engine), true)
                    } catch {
                        return (engine, nil, false)
                    }
                }
            }
            for await (engine, profile, succeeded) in group {
                if succeeded { successfulFetches += 1 }
                if let profile, !profile.capabilities.isEmpty {
                    byEngine[engine] = profile
                }
            }
        }
        var aggregateCapabilities: AtlasArenaCapabilities?
        if byEngine.isEmpty {
            // Perfil por motor ausente ([]), mas o agregado global pode
            // existir (engine vazio → todos os motores; proveniência DITA).
            if let aggregate = try? await client.getArenaCapabilities(engine: "") {
                successfulFetches += 1
                aggregateCapabilities = aggregate.capabilities.isEmpty ? nil : aggregate
            }
        } else {
            aggregateCapabilities = composite.engines.first.flatMap { byEngine[$0.engine] }
        }
        guard !preserveCurrentOnTotalFailure || successfulFetches > 0 else { return }
        if capabilitiesByEngine != byEngine {
            capabilitiesByEngine = byEngine
        }
        if capabilities != aggregateCapabilities {
            capabilities = aggregateCapabilities
        }
    }

    /// Publica somente mudança semântica do feed. `generated_at` muda a cada
    /// poll, mas não deve invalidar a árvore inteira quando os runs são iguais.
    func publishLiveRuns(_ next: AtlasArenaLiveRuns?) {
        guard let next, liveRuns?.runs != next.runs else { return }
        liveRuns = next
    }

    var preferredEngine: String? {
        composite?.engines.first?.engine
            ?? scoreboard?.suites.lazy.flatMap(\.engines).first?.engine
    }

    /// Fonte única para AGORA: running, fila, falha e estado desconhecido não
    /// são reclassificados pela casca. `nil` significa feed ainda não publicado.
    var livePresentation: AtlasArenaLivePresentation? {
        liveRuns?.presentation
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
#if DEBUG
        // Cenário visual de UITest não pode ser apagado por refresh/rede.
        if visualScenarioInstalled { return }
#endif
        phase = .loading
        controlError = nil
        loadFailureKind = nil
        isDomainUnavailable = false
        do {
            async let compositeRequest = client.getArenaComposite()
            async let scoreboardRequest = client.getArenaScoreboard()
            let (nextComposite, nextScoreboard) = try await (compositeRequest, scoreboardRequest)
            async let reportRequest: AtlasArenaReport? = try? client.getArenaReport()
            async let liveRunsRequest: AtlasArenaLiveRuns? = try? client.getArenaLiveRuns()
            async let engineCatalogRequest: AtlasArenaEngines? = try? client.getArenaEngines()
            // Capacidades ANTES de publicar o composite: @Observable re-renderiza
            // na 1ª atribuição, e o hero não pode nascer dizendo "não medida"
            // enquanto o fetch ainda está em voo (estado atômico, nunca meia-tela).
            await loadCapabilities(for: nextComposite)
            composite = nextComposite
            scoreboard = nextScoreboard
            report = await reportRequest
            publishLiveRuns(await liveRunsRequest)
            engineCatalog = await engineCatalogRequest
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
