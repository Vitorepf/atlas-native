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
            composite = nextComposite
            scoreboard = nextScoreboard
            markLoaded()
            if case .idle = phase { phase = .loaded }
        } catch {
            controlError = Self.publicMessage(error)
        }
    }

    func refreshLiveRuns() async {
        do {
            liveRuns = try await client.getArenaLiveRuns()
            updateLivePolling()
        } catch {
            controlError = Self.publicMessage(error)
        }
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
