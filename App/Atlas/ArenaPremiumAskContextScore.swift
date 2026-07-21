import Foundation
import AtlasCore

// WAVE-171 density peel — Arena pack score / fleet / suite organs

extension ArenaPremiumAskContext {
    @MainActor
    // MARK: - Fleet · capabilities · run sheet · suites
    static func appendScoreOrgans(
        model: ArenaModel,
        destination: ArenaPremiumDestination?,
        tab: ArenaPremiumTab,
        focusTab: ArenaPremiumTab,
        liveRuns: [AtlasArenaLiveRun],
        into facts: inout [String],
        absences: inout [String]
    ) {
        if focusTab == .fleet || destination == nil && tab == .fleet {
            let fleetPack = ArenaFleetJudgment.packFacts(engines: model.composite?.engines ?? [])
            facts.append(contentsOf: fleetPack.facts)
            absences.append(contentsOf: fleetPack.absences)
        }
        if focusTab == .capabilities || destination == nil && tab == .capabilities {
            let caps = model.selectedCapabilities?.capabilities ?? []
            let capPack = ArenaCapabilitiesJudgment.packFacts(caps)
            facts.append(contentsOf: capPack.facts)
            absences.append(contentsOf: capPack.absences)
        }

        let enginesPublished = model.engineCatalog?.engines.count
            ?? model.composite?.engines.count
            ?? 0
        let suitesPublished = model.activePlan?.suites.count
            ?? model.livePresentation?.queuedRuns.count
            ?? 0

        let runSheetPack = ArenaRunSheetJudgment.packFacts(
            engineCount: enginesPublished,
            suiteCount: suitesPublished
        )
        facts.append(contentsOf: runSheetPack.facts)
        absences.append(contentsOf: runSheetPack.absences)

        if focusTab == .results || destination == .results || destination == .alerts
            || (destination == nil && tab == .now)
        {
            let suites = model.scoreboard?.suites ?? []
            if suites.isEmpty {
                absences.append("scoreboard sem suites publicadas neste recorte")
            } else {
                let ranked = suites.enumerated().sorted { lhs, rhs in
                    let l = lhs.element.hasRegression
                    let r = rhs.element.hasRegression
                    if l != r { return l && !r }
                    return lhs.offset < rhs.offset
                }.map(\.element)
                for suite in ranked.prefix(4) {
                    let suitePack = ArenaSuiteJudgment.packFacts(for: suite)
                    facts.append(contentsOf: suitePack.facts)
                    absences.append(contentsOf: suitePack.absences)
                }
            }
        }
    }
}
