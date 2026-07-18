import Foundation
import AtlasCore

// Polling de runs vivos — peel de ArenaModel (régua ~120).

extension ArenaModel {
    var shouldPollLiveRuns: Bool {
        // Só visibilidade: exigir feed não-vazio criava ovo-e-galinha — um
        // fetch falho (nil) ou fila vazia desligava o polling PARA SEMPRE e
        // a seção AGORA nunca mais voltava (worker medindo, tela muda,
        // 2026-07-18). Custo: 1 GET ~130ms a cada 10s enquanto visível.
        visible
    }

    func updateLivePolling() {
        guard shouldPollLiveRuns else {
            livePollingTask?.cancel()
            livePollingTask = nil
            return
        }
        guard livePollingTask == nil else { return }
        livePollingTask = Task { @MainActor [weak self] in
            while let self, !Task.isCancelled, self.shouldPollLiveRuns {
                try? await Task.sleep(for: .seconds(10))
                guard !Task.isCancelled, self.shouldPollLiveRuns else { break }
                await self.refreshLiveRuns()
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
