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

    /// Fatos em prosa humana — tab **e** destination (nunca forçar Agora em destinos).
    @MainActor
    static func facts(
        model: ArenaModel,
        tab: ArenaPremiumTab,
        destination: ArenaPremiumDestination? = nil
    ) -> String {
        var lines: [String] = [
            "Contexto Arena (medição). Use este pack da ocasião; intenção do operador pode pedir outro mundo — o pack local anexa sempre.",
        ]
        if let destination {
            lines.append("Tela: \(destinationLabel(destination)).")
        } else {
            lines.append("Aba: \(tab.rawValue).")
        }
        if let engine = model.arenaPrimaryEngine {
            lines.append("Motor em foco: \(ArenaDisplay.engine(engine.engine)).")
            lines.append("Índice composto: \(ArenaFormat.score(engine.composite)) / 10.")
            lines.append("Sem Atlas: \(ArenaFormat.score(engine.withoutAtlasComposite)); com Atlas: \(ArenaFormat.score(engine.withAtlasComposite)).")
            if let mult = engine.atlasMultiplier {
                lines.append("Multiplicador Atlas: \(ArenaFormat.multiplier(mult)).")
            }
            if engine.isPartialCoverage {
                lines.append("Cobertura parcial.")
            }
        } else {
            lines.append("Nenhum motor composto publicado ainda.")
        }
        lines.append("Cobertura: \(model.arenaCoverageText).")
        if let phase = model.livePresentation?.phase {
            lines.append("Fase ao vivo: \(phaseLabel(phase)).")
        }
        if let progress = model.livePresentation?.progress {
            lines.append("Progresso: \(progress.completed) de \(progress.total) casos (\(progress.remaining) restantes).")
        }
        if let run = model.arenaPrimaryRun {
            lines.append("Corrida: \(ArenaDisplay.suite(run.suite)) · \(run.arm?.labelPT ?? "braço") · \(run.status.displayPT).")
        }
        let alerts = model.arenaAlertSuiteCount
        lines.append(alerts == 0 ? "Alertas: nenhuma exceção." : "Alertas: \(alerts) exceção(ões).")
        if let narrative = model.report?.narrative, !narrative.isEmpty {
            lines.append("Narrativa publicada: \(narrative)")
        }
        let focusTab = destination == nil ? tab : tabForDestination(destination!)
        if focusTab == .fleet || destination == nil && tab == .fleet, let composite = model.composite {
            lines.append("Frota (\(composite.engines.count) motores), ordenada por ganho Atlas:")
            for engine in composite.engines.prefix(8) {
                let mult = engine.atlasMultiplier.map(ArenaFormat.multiplier) ?? "não medido"
                lines.append("- \(ArenaDisplay.engine(engine.engine)): \(mult) (sem \(ArenaFormat.score(engine.withoutAtlasComposite)) → com \(ArenaFormat.score(engine.withAtlasComposite)))")
            }
        }
        if focusTab == .capabilities || destination == nil && tab == .capabilities {
            let caps = model.selectedCapabilities?.capabilities ?? []
            let covered = caps.filter { $0.score != nil || $0.withAtlas != nil }.count
            lines.append("Capacidades no perfil: \(covered) cobertas de \(caps.count).")
            for cap in caps.prefix(8) {
                let d: Double? = {
                    guard let a = cap.withAtlas, let b = cap.score else { return nil }
                    return a - b
                }()
                lines.append("- \(cap.labelPt): sem \(ArenaFormat.score(cap.score)) → com \(ArenaFormat.score(cap.withAtlas)) (\(ArenaFormat.signed(d)))")
            }
        }
        if destination == .execution || destination == .queue {
            let live = model.liveRuns?.runs ?? []
            lines.append("Corridas publicadas em live: \(live.count).")
            for run in live.prefix(6) {
                lines.append("- \(ArenaDisplay.suite(run.suite)) · \(run.arm?.labelPT ?? "braço") · \(run.status.displayPT)")
            }
            if live.isEmpty {
                lines.append("Ausência: nenhuma corrida live publicada.")
            }
        }
        if destination == .plan {
            if model.activePlan != nil {
                lines.append("Há plano ativo real no model.")
            } else {
                lines.append("Ausência: sem plano multi-suíte publicado (não invente progresso de plano).")
            }
        }
        lines.append("Ausências: não invente scores; diga “não medido” quando faltar braço ou suíte.")
        lines.append("Ações run/stop: use os controles da Arena (NL de chat ainda não autoriza tools de escrita no wire).")
        return lines.joined(separator: "\n")
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

    private static func tabForDestination(_ d: ArenaPremiumDestination) -> ArenaPremiumTab {
        switch d {
        case .execution, .queue, .plan, .alerts: .now
        case .results: .results
        }
    }

    private static func phaseLabel(_ phase: AtlasArenaLivePhase) -> String {
        switch phase {
        case .idle: "parada"
        case .queued: "na fila"
        case .running: "ao vivo"
        case .stopping: "parando"
        case .stopped: "parada pelo operador"
        case .completed: "concluída"
        case .failed: "interrompida"
        }
    }
}
