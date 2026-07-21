import Foundation
import AtlasCore

/// Pack de contexto Arena — presentation-only até o contrato Core (§5).
/// Nunca vaza na cara da pílula; só viaja como `turnFacts` humanos.
/// Pack = tela/destino atual; intenção cross-world **não** é bloqueada no texto.
/// WAVE-171 density peel — host invite/canDo + facts shell.
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
    // MARK: - Shell pack (WAVE-186)

    /// Arena shell identity — tela/aba · cobertura · engine anchor only.
    static func packShellFacts(
        tab: ArenaPremiumTab,
        destination: ArenaPremiumDestination?,
        coverageText: String,
        primaryEngineLabel: String?
    ) -> (facts: [String], absences: [String], anchors: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        var anchors: [String] = []
        if let destination {
            facts.append("tela: \(destinationLabel(destination))")
            anchors.append("dest: \(destinationLabel(destination))")
        } else {
            facts.append("aba: \(tab.rawValue)")
            anchors.append("tab: \(tab.rawValue)")
        }
        if let primaryEngineLabel {
            anchors.append("engine: \(primaryEngineLabel)")
        }
        facts.append("cobertura_texto: \(coverageText)")
        absences.append("não invente scores; diga “não medido” quando faltar braço ou suíte")
        absences.append("pack Core tipado Arena ainda §5 — este é presentation-only")
        return (facts, absences, anchors)
    }

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

        // WAVE-186: shell pack (tela/aba · cobertura · engine anchor).
        let engineLabel = model.arenaPrimaryEngine.map { ArenaDisplay.engine($0.engine) }
        let shell = packShellFacts(
            tab: tab,
            destination: destination,
            coverageText: model.arenaCoverageText,
            primaryEngineLabel: engineLabel
        )
        facts.append(contentsOf: shell.facts)
        absences.append(contentsOf: shell.absences)
        anchors.append(contentsOf: shell.anchors)

        let liveRuns = model.liveRuns?.runs ?? []
        let primary = model.arenaPrimaryRun
        let focusTab = destination == nil ? tab : tabForDestination(destination!)

        appendLiveControlOrgans(
            model: model,
            destination: destination,
            tab: tab,
            liveRuns: liveRuns,
            primary: primary,
            into: &facts,
            absences: &absences
        )
        appendScoreOrgans(
            model: model,
            destination: destination,
            tab: tab,
            focusTab: focusTab,
            liveRuns: liveRuns,
            into: &facts,
            absences: &absences
        )

        let canDo = occasionCanDo(
            tab: tab,
            destination: destination,
            primary: primary
        )
        if !ArenaLiveControlJudgment.canStop(primary: primary) {
            absences.append("parada indisponível — sem primary stoppable / measurementId")
        }

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

    static func destinationLabel(_ d: ArenaPremiumDestination) -> String {
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
