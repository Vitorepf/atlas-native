import Foundation
import AtlasCore

/// Pack de contexto Arena — presentation-only até o contrato Core (§5).
/// Nunca vaza na cara da pílula; só viaja como `turnFacts` humanos.
/// Pack = tela/destino atual; intenção cross-world **não** é bloqueada no texto.
enum ArenaPremiumAskContext {
    // MARK: - Invite / empty

    static func invite(tab: ArenaPremiumTab, destination: ArenaPremiumDestination?) -> String {
        if let destination {
            switch destination {
            case .execution: return "pergunte sobre esta execução"
            case .queue: return "pergunte sobre a fila"
            case .alerts: return "pergunte sobre estes alertas"
            case .plan: return "pergunte sobre este plano"
            case .results: return "pergunte sobre este motor"
            }
        }
        switch tab {
        case .now: return "pergunte sobre esta medição"
        case .fleet: return "pergunte sobre a frota medida"
        case .capabilities: return "pergunte sobre estas capacidades"
        case .results: return "pergunte sobre este motor"
        }
    }

    /// Suggestions calibradas ao can-do atual (NL chat = leitura; run/stop = CTA).
    static func emptySuggestions(
        tab: ArenaPremiumTab,
        destination: ArenaPremiumDestination? = nil
    ) -> [String] {
        if let destination {
            switch destination {
            case .execution:
                return [
                    "Como está o progresso da execução?",
                    "Onde o Atlas está ganhando nestas corridas?",
                    "Qual corrida precisa de atenção?"
                ]
            case .queue:
                return [
                    "O que está na fila?",
                    "Qual suíte vem a seguir?",
                    "Há bloqueio na fila?"
                ]
            case .alerts:
                return [
                    "Quais alertas importam agora?",
                    "Onde o Atlas regressou?",
                    "Qual suíte abriu exceção?"
                ]
            case .plan:
                return [
                    "Resuma o plano de medição",
                    "O que falta no plano?",
                    "Há plano ativo real?"
                ]
            case .results:
                return [
                    "Explica o índice deste motor",
                    "Quais suítes puxaram o ganho?",
                    "Onde a cobertura é parcial?"
                ]
            }
        }
        switch tab {
        case .now:
            return [
                "Como está o progresso agora?",
                "Onde o Atlas está ganhando nesta medição?",
                "Qual o status ao vivo?"
            ]
        case .fleet:
            return [
                "Qual motor sobe mais com Atlas?",
                "Onde o Atlas regressa na frota?",
                "Compara os motores medidos"
            ]
        case .capabilities:
            return [
                "Quais capacidades regrediram?",
                "Onde o Atlas sobe neste perfil?",
                "Resumo das capacidades cobertas"
            ]
        case .results:
            return [
                "Explica o índice deste motor",
                "Quais suítes puxaram o ganho?",
                "Onde a cobertura é parcial?"
            ]
        }
    }

    /// Pack WAVE-020 — tab **e** destination (nunca forçar Agora em destinos).
    // MARK: - Facts pack

    @MainActor
    static func facts(
        model: ArenaModel,
        tab: ArenaPremiumTab,
        destination: ArenaPremiumDestination? = nil
    ) -> String {
        var anchors: [String] = []
        var facts: [String] = []
        var absences: [String] = []

        if let destination {
            facts.append("tela: \(destinationLabel(destination))")
            anchors.append("dest: \(destinationLabel(destination))")
        } else {
            facts.append("aba: \(tab.rawValue)")
            anchors.append("tab: \(tab.rawValue)")
        }

        if let engine = model.arenaPrimaryEngine {
            facts.append("motor: \(ArenaDisplay.engine(engine.engine))")
            facts.append("indice_composto: \(ArenaFormat.score(engine.composite)) / 10")
            facts.append("sem_atlas: \(ArenaFormat.score(engine.withoutAtlasComposite)); com_atlas: \(ArenaFormat.score(engine.withAtlasComposite))")
            if let mult = engine.atlasMultiplier {
                facts.append("multiplicador: \(ArenaFormat.multiplier(mult))")
            }
            if engine.isPartialCoverage {
                facts.append("cobertura: parcial")
            }
            anchors.append("engine: \(ArenaDisplay.engine(engine.engine))")
        } else {
            absences.append("nenhum motor composto publicado ainda")
        }

        facts.append("cobertura_texto: \(model.arenaCoverageText)")

        // WAVE-083: Now + LiveControl packFacts (Judgment law — not ad-hoc phase).
        let livePhase = model.livePresentation?.phase
        let nowPack = ArenaNowJudgment.packFacts(
            loadPhase: model.phase,
            livePhase: livePhase,
            compositeNil: model.composite == nil,
            engineTitle: model.arenaLiveEngineTitle
        )
        facts.append(contentsOf: nowPack.facts)
        absences.append(contentsOf: nowPack.absences)

        let liveRuns = model.liveRuns?.runs ?? []
        let primary = model.arenaPrimaryRun
        let livePack = ArenaLiveControlJudgment.packFacts(runs: liveRuns, primary: primary)
        facts.append(contentsOf: livePack.facts)
        absences.append(contentsOf: livePack.absences)

        if let progress = model.livePresentation?.progress {
            facts.append("progresso: \(progress.completed)/\(progress.total) (\(progress.remaining) restantes)")
        }
        if let run = primary {
            // WAVE-157: RunStatusJudgment productWord — one law with list/detail UI.
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

        let focusTab = destination == nil ? tab : tabForDestination(destination!)
        // WAVE-157: fleet pack order ≡ FleetView rank.
        if focusTab == .fleet || destination == nil && tab == .fleet {
            let fleetPack = ArenaFleetJudgment.packFacts(engines: model.composite?.engines ?? [])
            facts.append(contentsOf: fleetPack.facts)
            absences.append(contentsOf: fleetPack.absences)
        }
        if focusTab == .capabilities || destination == nil && tab == .capabilities {
            // WAVE-094: measured confidence one law — never score-presence as cobertas.
            let caps = model.selectedCapabilities?.capabilities ?? []
            let capPack = ArenaCapabilitiesJudgment.packFacts(caps)
            facts.append(contentsOf: capPack.facts)
            absences.append(contentsOf: capPack.absences)
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

        // WAVE-157: pipeline organ when execution / now live has published runs.
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

        // WAVE-157: stop organ — wire when canStop; sheet-local actor/reason → honest absence.
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

        // WAVE-157: start organ when receipt or run-sheet context (engines/suites published).
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
        // WAVE-085: plan/queue faces — never "sem plano" when UI is derived_live.
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

        // WAVE-166: run-sheet organ (engines × suites ready face).
        let runSheetPack = ArenaRunSheetJudgment.packFacts(
            engineCount: enginesPublished,
            suiteCount: suitesPublished
        )
        facts.append(contentsOf: runSheetPack.facts)
        absences.append(contentsOf: runSheetPack.absences)

        // WAVE-166: suite drill organs when scoreboard published (results/alerts/now).
        if focusTab == .results || destination == .results || destination == .alerts
            || (destination == nil && tab == .now)
        {
            let suites = model.scoreboard?.suites ?? []
            if suites.isEmpty {
                absences.append("scoreboard sem suites publicadas neste recorte")
            } else {
                // Regression-first; stable secondary (wire order).
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

        let canDo = occasionCanDo(
            tab: tab,
            destination: destination,
            primary: primary
        )
        if !ArenaLiveControlJudgment.canStop(primary: primary) {
            absences.append("parada indisponível — sem primary stoppable / measurementId")
        }

        absences.append("não invente scores; diga “não medido” quando faltar braço ou suíte")
        absences.append("pack Core tipado Arena ainda §5 — este é presentation-only")

        return AgenticOccasionPack(
            surface: "arena",
            subject: destination.map { "Arena · \(destinationLabel($0))" } ?? "Arena · \(tab.rawValue)",
            anchors: anchors,
            facts: facts,
            absences: absences,
            canDo: canDo
        ).render()
    }

    /// WAVE-083: can_do from live face — never always ctaOnlyRunStop.
    // MARK: - Can-do / destinations

    static func occasionCanDo(
        tab: ArenaPremiumTab,
        destination: ArenaPremiumDestination?,
        primary: AtlasArenaLiveRun?
    ) -> AgenticOccasionPack.CanDo {
        if ArenaLiveControlJudgment.canStop(primary: primary) {
            return .ctaOnlyRunStop
        }
        // Browse / results / fleet / capabilities — read only.
        if let destination {
            switch destination {
            case .execution, .queue, .alerts, .plan:
                return .readChat
            case .results:
                return .readChat
            }
        }
        switch tab {
        case .now:
            // Idle/terminal now: chat read; start remains CTA on face (not NL write).
            return .faceCTALocal
        case .fleet, .capabilities, .results:
            return .readChat
        }
    }

    private static func destinationLabel(_ d: ArenaPremiumDestination) -> String {
        switch d {
        case .execution: "Execução"
        case .plan: "Plano"
        case .queue: "Fila"
        case .alerts: "Alertas"
        case .results: "Motor"
        }
    }

    /// Tab canônica para um destino (nunca forçar Agora na cara do pack de destinos).
    static func tabForDestination(_ d: ArenaPremiumDestination) -> ArenaPremiumTab {
        switch d {
        case .execution, .queue, .plan, .alerts: .now
        case .results: .results
        }
    }

}
