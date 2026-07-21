import AtlasCore
import Foundation
import Observation

// IDLE-COMPRESS ArenaModel fused

// WAVE-138 ArenaModel host state

@MainActor
@Observable
final class ArenaModel {
    let client: AtlasClient

    var phase: LoadPhase = .idle
    var composite: AtlasArenaComposite?
    var scoreboard: AtlasArenaScoreboard?
    var report: AtlasArenaReport?
    var capabilities: AtlasArenaCapabilities?
    var capabilitiesByEngine: [String: AtlasArenaCapabilities] = [:]
    var capabilitiesEngineSelection: String?
    var liveRuns: AtlasArenaLiveRuns?
    var engineCatalog: AtlasArenaEngines?
    var lastStartReceipt: AtlasArenaStartReceipt?
    var lastStopReceipt: AtlasArenaStopReceipt?
    var activePlan: AtlasArenaMeasurementPlan?
    var lastStartReceipts: [AtlasArenaStartReceipt] = []
    var isStartingRuns = false
    var isStoppingMeasurement = false
    var lastStartEnginesCount = 0
    var lastStartRunsPlannedTotal = 0
    var controlError: String?
    private(set) var loadFailureKind: AtlasNetworkFailureKind?
    private(set) var isDomainUnavailable = false
    private(set) var lastLoadedAt: Date?

    func markLoaded() { lastLoadedAt = Date() }
    var visible = false
    var livePollingTask: Task<Void, Never>?
#if DEBUG
    var visualScenarioInstalled = false
#endif

    static let domainUnavailableCopy = "medição ainda não publicada pelo servidor"

    init(client: AtlasClient) {
        self.client = client
    }

    var capabilityEngineOptions: [String] {
        (composite?.engines.map(\.engine) ?? []).filter { capabilitiesByEngine[$0] != nil }
    }

    var selectedCapabilities: AtlasArenaCapabilities? {
        if let selection = capabilitiesEngineSelection, let chosen = capabilitiesByEngine[selection] {
            return chosen
        }
        return capabilityEngineOptions.first.flatMap { capabilitiesByEngine[$0] } ?? capabilities
    }

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

    func publishLiveRuns(_ next: AtlasArenaLiveRuns?) {
        guard let next, liveRuns?.runs != next.runs else { return }
        liveRuns = next
    }

    var preferredEngine: String? {
        composite?.engines.first?.engine
            ?? scoreboard?.suites.lazy.flatMap(\.engines).first?.engine
    }

    var livePresentation: AtlasArenaLivePresentation? {
        liveRuns?.presentation
    }

    var regressionException: String? {
        for suite in scoreboard?.suites ?? [] {
            guard let engine = suite.engines.first(where: \.regressed),
                  let delta = engine.delta else { continue }
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
