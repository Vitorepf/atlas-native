#if DEBUG
import Foundation
import AtlasCore

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
