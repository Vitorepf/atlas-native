import Foundation
import AtlasCore

// Refresh/start sem polling — peel de ArenaModel (régua ~120).

extension ArenaModel {
    func refreshSummaryKeepingSnapshot() async {
        controlError = nil
        do {
            async let compositeRequest = client.getArenaComposite()
            async let scoreboardRequest = client.getArenaScoreboard()
            let (nextComposite, nextScoreboard) = try await (compositeRequest, scoreboardRequest)
            // Capacidades acompanham o snapshot: refresh sem elas deixava o
            // hero dizendo "nenhuma medida" com medição real viva no servidor.
            await loadCapabilities(for: nextComposite)
            composite = nextComposite
            scoreboard = nextScoreboard
            markLoaded()
            if case .idle = phase { phase = .loaded }
            // O feed vivo acompanha o snapshot: sem isto, revisita da tela
            // ficava com liveRuns nil e a seção AGORA sumia.
            await refreshLiveRuns()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }

    func refreshLiveRuns() async {
        // Ambiente (polling 10s): falha transitória não vira banner — a seção
        // AGORA segue com o último feed conhecido e o próximo tick tenta de novo.
        liveRuns = (try? await client.getArenaLiveRuns()) ?? liveRuns
        updateLivePolling()
    }

    /// Um POST B5 por motor (goal 1: motor contra motor numa medição só).
    func startRuns(inputs: [AtlasArenaStartInput]) async {
        controlError = nil
        guard !inputs.isEmpty, inputs.allSatisfy(\.isLocallyValidForSubmission) else {
            controlError = "ator e motivo obrigatórios"
            return
        }
        do {
            var plannedTotal = 0
            for input in inputs {
                let receipt = try await client.startArenaRuns(input: input)
                plannedTotal += receipt.runsPlanned
                lastStartReceipt = receipt
            }
            lastStartEnginesCount = inputs.count
            lastStartRunsPlannedTotal = plannedTotal
            await refreshLiveRuns()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }
}
