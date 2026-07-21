import Foundation
import AtlasCore

// WAVE-171 density peel — Arena pack live control organs

extension ArenaPremiumAskContext {
    @MainActor
    static func appendLiveControlOrgans(
        model: ArenaModel,
        destination: ArenaPremiumDestination?,
        tab: ArenaPremiumTab,
        liveRuns: [AtlasArenaLiveRun],
        primary: AtlasArenaLiveRun?,
        into facts: inout [String],
        absences: inout [String]
    ) {
        let livePhase = model.livePresentation?.phase
        let nowPack = ArenaNowJudgment.packFacts(
            loadPhase: model.phase,
            livePhase: livePhase,
            compositeNil: model.composite == nil,
            engineTitle: model.arenaLiveEngineTitle
        )
        facts.append(contentsOf: nowPack.facts)
        absences.append(contentsOf: nowPack.absences)

        let livePack = ArenaLiveControlJudgment.packFacts(runs: liveRuns, primary: primary)
        facts.append(contentsOf: livePack.facts)
        absences.append(contentsOf: livePack.absences)

        if let progress = model.livePresentation?.progress {
            facts.append("progresso: \(progress.completed)/\(progress.total) (\(progress.remaining) restantes)")
        }
        if let run = primary {
            facts.append(
                "corrida: \(ArenaDisplay.suite(run.suite)) · \(run.arm?.labelPT ?? "braço") · \(ArenaRunStatusJudgment.productWord(for: run.status))"
            )
            let statusPack = ArenaRunStatusJudgment.packFacts(for: run.status)
            facts.append(contentsOf: statusPack.facts)
            absences.append(contentsOf: statusPack.absences)
        }
        let alerts = model.arenaAlertSuiteCount
        facts.append(alerts == 0 ? "alertas: nenhuma exceção" : "alertas: \(alerts) exceção(ões)")
        if let narrative = model.report?.narrative, !narrative.isEmpty {
            facts.append("narrativa: \(narrative)")
        }

        if destination == .execution || destination == .queue {
            facts.append("corridas_live: \(liveRuns.count)")
            let orderedLive = ArenaLiveControlJudgment.rank(liveRuns)
            for run in orderedLive.prefix(6) {
                facts.append(
                    "live · \(ArenaDisplay.suite(run.suite)) · \(run.arm?.labelPT ?? "braço") · \(ArenaRunStatusJudgment.productWord(for: run.status))"
                )
            }
            if liveRuns.isEmpty {
                absences.append("nenhuma corrida live publicada")
            }
        }

        if destination == .execution || (destination == nil && tab == .now && !liveRuns.isEmpty) {
            let planArms = model.activePlan?.arms ?? []
            let projection = ArenaPipelineJudgment.project(
                runs: model.arenaPrimaryMeasurementRuns,
                expectsBare: planArms.contains(.baseline) || model.arenaPrimaryMeasurementRuns.contains { $0.arm == .baseline },
                expectsAtlas: planArms.contains(.withAtlas) || model.arenaPrimaryMeasurementRuns.contains { $0.arm == .withAtlas },
                hasReport: model.report != nil
            )
            let pipePack = ArenaPipelineJudgment.packFacts(projection)
            facts.append(contentsOf: pipePack.facts)
            absences.append(contentsOf: pipePack.absences)
        }

        if ArenaLiveControlJudgment.canStop(primary: primary) {
            let hasReceipt = model.lastStopReceipt?.measurementIdPublic == primary?.measurementIdPublic
            let stopPack = ArenaStopJudgment.packFacts(
                actor: "",
                reason: "",
                hasMatchingReceipt: hasReceipt
            )
            facts.append(contentsOf: stopPack.facts)
            absences.append(contentsOf: stopPack.absences)
            absences.append("stop_sheet: face-only — actor/motivo só no modal de parada")
        }

        let enginesPublished = model.engineCatalog?.engines.count
            ?? model.composite?.engines.count
            ?? 0
        let suitesPublished = model.activePlan?.suites.count
            ?? model.livePresentation?.queuedRuns.count
            ?? 0
        if model.lastStartReceipt != nil
            || destination == .execution
            || destination == .plan
            || (destination == nil && tab == .now)
        {
            let startPack = ArenaStartJudgment.packFacts(
                input: nil,
                receipt: model.lastStartReceipt,
                enginesPublished: enginesPublished,
                suitesPublished: suitesPublished
            )
            facts.append(contentsOf: startPack.facts)
            absences.append(contentsOf: startPack.absences)
        }

        if destination == .plan {
            let planPack = ArenaPlanQueueJudgment.planPackFacts(
                activePlan: model.activePlan,
                measurementRuns: model.arenaPrimaryMeasurementRuns,
                queuedRuns: model.livePresentation?.queuedRuns ?? []
            )
            facts.append(contentsOf: planPack.facts)
            absences.append(contentsOf: planPack.absences)
        }
        if destination == .queue {
            let queuePack = ArenaPlanQueueJudgment.queuePackFacts(
                queuedRuns: model.livePresentation?.queuedRuns ?? []
            )
            facts.append(contentsOf: queuePack.facts)
            absences.append(contentsOf: queuePack.absences)
        }
    }
}
