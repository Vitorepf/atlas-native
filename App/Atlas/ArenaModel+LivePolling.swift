import Foundation
import AtlasCore

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
