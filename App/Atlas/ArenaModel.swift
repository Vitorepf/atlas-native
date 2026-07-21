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


// Polling de runs vivos — peel de ArenaModel (régua ~120).

extension ArenaModel {
    var shouldPollLiveRuns: Bool {
#if DEBUG
        if visualScenarioInstalled { return false }
#endif
        // Só visibilidade: exigir feed não-vazio criava ovo-e-galinha — um
        // fetch falho (nil) ou fila vazia desligava o polling PARA SEMPRE e
        // a seção AGORA nunca mais voltava (worker medindo, tela muda,
        // 2026-07-18). Custo: 1 GET ~130ms a cada 10s enquanto visível.
        return visible
    }

    func updateLivePolling() {
        guard shouldPollLiveRuns else {
            livePollingTask?.cancel()
            livePollingTask = nil
            return
        }
        guard livePollingTask == nil else { return }
        livePollingTask = Task { @MainActor [weak self] in
            var lastFullRefresh = ContinuousClock.now
            while let self, !Task.isCancelled, self.shouldPollLiveRuns {
                try? await Task.sleep(for: .seconds(10))
                guard !Task.isCancelled, self.shouldPollLiveRuns else { break }
                let runsBefore = self.liveRuns?.runs
                await self.refreshLiveRuns()
                // Medição nova aparece em SEGUNDOS (ordem do operador, 20/07):
                // run vivo transicionou → refresh completo (capacidades +
                // scoreboard + report) NA HORA. Fallback de 30s cobre o que não
                // passa pela fila viva (batteries importam ao fim da suíte).
                let transitioned = runsBefore != self.liveRuns?.runs
                if transitioned || ContinuousClock.now - lastFullRefresh > .seconds(30) {
                    lastFullRefresh = ContinuousClock.now
                    await self.refreshSummaryKeepingSnapshot(quiet: true)
                }
            }
        }
    }

    static func publicMessage(_ error: Error) -> String {
        if isDomainUnavailableError(error) {
            return domainUnavailableCopy
        }
        if let api = error as? AtlasApiError { return api.message }
        return "não foi possível carregar a Arena"
    }

    static func isDomainUnavailableError(_ error: Error) -> Bool {
        (error as? AtlasApiError)?.status == 404
    }
}

#if DEBUG

extension ArenaModel {
    @discardableResult
    func installVisualScenarioIfRequested(
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) -> Bool {
        guard !visualScenarioInstalled,
              let raw = arguments.value(after: "-atlas.arena.scenario") else {
            return visualScenarioInstalled
        }

        do {
            let snapshot = try AtlasArenaVisualFixture.snapshot(scenario: raw)
            composite = snapshot.composite
            scoreboard = snapshot.scoreboard
            report = snapshot.report
            capabilities = snapshot.capabilities
            capabilitiesByEngine = ["verboo_kimi_k2_7": snapshot.capabilities]
            capabilitiesEngineSelection = "verboo_kimi_k2_7"
            engineCatalog = snapshot.engineCatalog
            liveRuns = snapshot.liveRuns
            activePlan = snapshot.plan
            phase = .loaded
            visualScenarioInstalled = true
            markLoaded()
            return true
        } catch {
            assertionFailure("Arena visual fixture inválida: \(error)")
            return false
        }
    }
}

private extension Array where Element == String {
    func value(after flag: String) -> String? {
        guard let index = firstIndex(of: flag), indices.contains(index + 1) else { return nil }
        return self[index + 1]
    }
}
#endif


// Refresh/start sem polling — peel de ArenaModel (régua ~120).

extension ArenaModel {
    /// `quiet`: refresh disparado pelo POLL — falha transitória não vira banner
    /// (o próximo tick tenta de novo); só o refresh manual mostra erro.
    func refreshSummaryKeepingSnapshot(quiet: Bool = false) async {
        if !quiet { controlError = nil }
        do {
            async let compositeRequest = client.getArenaComposite()
            async let scoreboardRequest = client.getArenaScoreboard()
            let (nextComposite, nextScoreboard) = try await (compositeRequest, scoreboardRequest)
            async let reportRequest: AtlasArenaReport? = try? client.getArenaReport()
            async let liveRunsRequest: AtlasArenaLiveRuns? = try? client.getArenaLiveRuns()
            // Capacidades acompanham o snapshot: refresh sem elas deixava o
            // hero dizendo "nenhuma medida" com medição real viva no servidor.
            await loadCapabilities(for: nextComposite, preserveCurrentOnTotalFailure: true)
            composite = nextComposite
            scoreboard = nextScoreboard
            report = await reportRequest ?? report
            publishLiveRuns(await liveRunsRequest)
            markLoaded()
            if case .idle = phase { phase = .loaded }
            updateLivePolling()
        } catch {
            if !quiet { controlError = Self.publicMessage(error) }
        }
    }

    /// Re-busca capacidades ao abrir a aba Capacidades. O poll de 10s só
    /// atualiza runs VIVAS; sem isto a aba ficava congelada no dado de antes
    /// da última medição (ou de antes de um fix de servidor), mostrando -X
    /// falso onde o servidor já dizia "não medido".
    func refreshCapabilities() async {
        guard let composite else { return }
        await loadCapabilities(for: composite, preserveCurrentOnTotalFailure: true)
    }

    func refreshLiveRuns() async {
        // Ambiente (polling 10s): falha transitória não vira banner — a seção
        // AGORA segue com o último feed conhecido e o próximo tick tenta de novo.
        publishLiveRuns(try? await client.getArenaLiveRuns())
        updateLivePolling()
    }

    /// Um POST B5 por motor (goal 1: motor contra motor numa medição só).
    func startRuns(inputs: [AtlasArenaStartInput]) async {
        guard !isStartingRuns else { return }
        controlError = nil
        guard let plan = AtlasArenaMeasurementPlan(inputs: inputs) else {
            controlError = "selecione suítes, motores e braços; informe ator e motivo"
            return
        }
        isStartingRuns = true
        defer { isStartingRuns = false }
        activePlan = plan
        lastStartReceipt = nil
        lastStartReceipts = []
        lastStartEnginesCount = 0
        lastStartRunsPlannedTotal = 0
        do {
            for input in inputs {
                let receipt = try await client.startArenaRuns(input: input)
                lastStartReceipt = receipt
                lastStartReceipts.append(receipt)
                lastStartEnginesCount = lastStartReceipts.count
                lastStartRunsPlannedTotal += receipt.runsPlanned
            }
            await refreshLiveRuns()
        } catch {
            if lastStartReceipts.isEmpty {
                controlError = Self.publicMessage(error)
            } else {
                controlError = "\(lastStartReceipts.count) de \(inputs.count) motores enfileirados · o restante não foi confirmado"
                await refreshLiveRuns()
            }
        }
    }

    func stopMeasurement(
        measurementId: String,
        operatorActor: String,
        operatorReason: String
    ) async {
        guard !isStoppingMeasurement else { return }
        let input = AtlasArenaStopInput(
            operatorActor: operatorActor,
            operatorReason: operatorReason
        )
        guard input.isLocallyValidForSubmission else {
            controlError = "informe operador e motivo para parar a medição"
            return
        }
        isStoppingMeasurement = true
        controlError = nil
        defer { isStoppingMeasurement = false }
        do {
            lastStopReceipt = try await client.stopArenaMeasurement(
                measurementId: measurementId,
                input: input
            )
            await refreshLiveRuns()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }
}
