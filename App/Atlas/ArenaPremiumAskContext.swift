import Foundation
import AtlasCore

/// Pack de contexto Arena — presentation-only até o contrato Core (§5).
/// Nunca vaza na cara da pílula; só viaja como `turnFacts` humanos.
/// Pack = tela/destino atual; intenção cross-world **não** é bloqueada no texto.
enum ArenaPremiumAskContext {
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
            facts.append("corrida: \(ArenaDisplay.suite(run.suite)) · \(run.arm?.labelPT ?? "braço") · \(run.status.displayPT)")
        }
        let alerts = model.arenaAlertSuiteCount
        facts.append(alerts == 0 ? "alertas: nenhuma exceção" : "alertas: \(alerts) exceção(ões)")
        if let narrative = model.report?.narrative, !narrative.isEmpty {
            facts.append("narrativa: \(narrative)")
        }

        let focusTab = destination == nil ? tab : tabForDestination(destination!)
        if focusTab == .fleet || destination == nil && tab == .fleet, let composite = model.composite {
            facts.append("frota_motores: \(composite.engines.count)")
            for engine in composite.engines.prefix(8) {
                let mult = engine.atlasMultiplier.map(ArenaFormat.multiplier) ?? "não medido"
                facts.append("frota · \(ArenaDisplay.engine(engine.engine)): \(mult) (sem \(ArenaFormat.score(engine.withoutAtlasComposite)) → com \(ArenaFormat.score(engine.withAtlasComposite)))")
            }
        }
        if focusTab == .capabilities || destination == nil && tab == .capabilities {
            let caps = model.selectedCapabilities?.capabilities ?? []
            let covered = caps.filter { $0.score != nil || $0.withAtlas != nil }.count
            facts.append("capacidades: \(covered) cobertas de \(caps.count)")
            for cap in caps.prefix(8) {
                let d: Double? = {
                    guard let a = cap.withAtlas, let b = cap.score else { return nil }
                    return a - b
                }()
                facts.append("cap · \(cap.labelPt): sem \(ArenaFormat.score(cap.score)) → com \(ArenaFormat.score(cap.withAtlas)) (\(ArenaFormat.signed(d)))")
            }
        }
        if destination == .execution || destination == .queue {
            facts.append("corridas_live: \(liveRuns.count)")
            for run in liveRuns.prefix(6) {
                facts.append("live · \(ArenaDisplay.suite(run.suite)) · \(run.arm?.labelPT ?? "braço") · \(run.status.displayPT)")
            }
            if liveRuns.isEmpty {
                absences.append("nenhuma corrida live publicada")
            }
        }
        if destination == .plan {
            if model.activePlan != nil {
                facts.append("plano_ativo: sim")
            } else {
                absences.append("sem plano multi-suíte publicado (não invente progresso de plano)")
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
