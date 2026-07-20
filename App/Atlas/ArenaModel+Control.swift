import Foundation
import AtlasCore

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
