import Foundation
import AtlasCore

/// Pack de contexto Arena — presentation-only até o contrato Core (§5).
/// Nunca vaza na cara da pílula; só viaja como `turnFacts` humanos.
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

    static func emptySuggestions(tab: ArenaPremiumTab) -> [String] {
        switch tab {
        case .now:
            return [
                "Como está o progresso agora?",
                "Onde o Atlas está ganhando nesta medição?",
                "Pare após o caso atual"
            ]
        case .fleet:
            return [
                "Qual motor sobe mais com Atlas?",
                "Onde o Atlas regressa na frota?",
                "Compara Opus e Kimi"
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
                "Roda outra medição neste motor"
            ]
        }
    }

    /// Fatos em prosa humana — sem slugs de wire na cara do agente como UI.
    @MainActor
    static func facts(model: ArenaModel, tab: ArenaPremiumTab) -> String {
        var lines: [String] = [
            "Contexto Arena (medição). Responda e aja só sobre esta superfície.",
            "Aba: \(tab.rawValue)."
        ]
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
        if tab == .fleet, let composite = model.composite {
            lines.append("Frota (\(composite.engines.count) motores), ordenada por ganho Atlas:")
            for engine in composite.engines.prefix(8) {
                let mult = engine.atlasMultiplier.map(ArenaFormat.multiplier) ?? "não medido"
                lines.append("- \(ArenaDisplay.engine(engine.engine)): \(mult) (sem \(ArenaFormat.score(engine.withoutAtlasComposite)) → com \(ArenaFormat.score(engine.withAtlasComposite)))")
            }
        }
        if tab == .capabilities {
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
        lines.append("Ausências: não invente scores; diga “não medido” quando faltar braço ou suíte.")
        return lines.joined(separator: "\n")
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
