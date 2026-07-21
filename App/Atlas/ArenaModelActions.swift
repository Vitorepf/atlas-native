import AtlasCore
import Foundation
import Observation

// IDLE-COMPRESS ArenaModel fused

// WAVE-138 ArenaModel actions peel

extension ArenaModel {
    func refreshSummaryKeepingSnapshot(quiet: Bool = false) async {
        if !quiet { controlError = nil }
        do {
            async let compositeRequest = client.getArenaComposite()
            async let scoreboardRequest = client.getArenaScoreboard()
            let (nextComposite, nextScoreboard) = try await (compositeRequest, scoreboardRequest)
            async let reportRequest: AtlasArenaReport? = try? client.getArenaReport()
            async let liveRunsRequest: AtlasArenaLiveRuns? = try? client.getArenaLiveRuns()
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

    func refreshCapabilities() async {
        guard let composite else { return }
        await loadCapabilities(for: composite, preserveCurrentOnTotalFailure: true)
    }

    func refreshLiveRuns() async {
        publishLiveRuns(try? await client.getArenaLiveRuns())
        updateLivePolling()
    }

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

extension ArenaModel {
    var regressionSummary: String? {
        let n = scoreboard?.suites.filter { suite in
            suite.engines.contains(where: \.regressed)
        }.count ?? 0
        guard n > 0 else { return nil }
        return n == 1 ? "1 regressão" : "\(n) regressões"
    }
}

extension ArenaModel {
    var shouldPollLiveRuns: Bool {
#if DEBUG
        if visualScenarioInstalled { return false }
#endif
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

