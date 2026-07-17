import Foundation

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
            lastLoadedAt = Date()
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

    func startRuns(input: AtlasArenaStartInput) async {
        controlError = nil
        guard input.isLocallyValidForSubmission else {
            controlError = "ator e motivo obrigatórios"
            return
        }
        do {
            lastStartReceipt = try await client.startArenaRuns(input: input)
            await refreshLiveRuns()
        } catch {
            controlError = Self.publicMessage(error)
        }
    }
}
