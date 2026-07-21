import Foundation
import AtlasCore

/// Pack de contexto Autônomos — WAVE-020 grammar + WAVE-026 decision subjects.
enum AutonomosAskContext {
    static func invite(destination: AutonomosDestination?, vestment: AutonomosHubVestment) -> String {
        if let destination {
            switch destination {
            case .hub:
                break
            case .decisions:
                return "qual decido primeiro?"
            case .decisionInbox, .decisionOrder:
                return "por que esse valor?"
            case .evolution:
                return "resuma isto"
            case .moment:
                return "por que isto?"
            case .incident:
                return "o que faço?"
            }
        }
        if destination == nil {
            return "o que mudou hoje?"
        }
        switch vestment {
        case .awaiting: return "o que preciso decidir?"
        case .live: return "o que ele fez hoje?"
        case .quiet: return "devo retomar?"
        }
    }

    static func emptySuggestions(destination: AutonomosDestination?) -> [String] {
        switch destination {
        case .decisions, .decisionInbox, .decisionOrder:
            return ["o que bloqueia?", "qual risco aceitar?"]
        case .incident:
            return ["o que quebrou?", "devo transferir?"]
        case .evolution, .moment:
            return ["o que mudou hoje?"]
        case .hub:
            return ["devo retomar?", "o que ele fez?"]
        case nil:
            return ["o que mudou hoje?", "qual Autônomo merece atenção?"]
        }
    }

    static func facts(
        unit: AutonomosUnit?,
        destination: AutonomosDestination?,
        backlog: AtlasAutonomosBacklogResponse? = nil,
        controlFace: AutonomosRunControlFace = .unbound,
        canControl: Bool = false,
        live: AtlasAutonomosLiveResponse? = nil,
        lastControlReceipt: AtlasAutonomosRunControlResponse? = nil,
        delivered: AtlasAutonomosDeliveredResponse? = nil,
        cycles: AtlasAutonomosCyclesResponse? = nil,
        lastTransferReceipt: AtlasAutonomosTransferResponse? = nil,
        taskHealth: AtlasAutonomosTaskHealthResponse? = nil,
        areaSelected: Bool = false,
        fleet: AtlasAutonomosFleetResponse? = nil,
        digest: AtlasAutonomosDigestResponse? = nil,
        areas: [AtlasAutonomosArea] = [],
        selectedAreaID: String? = nil
    ) -> String {
        var anchors: [String] = []
        var facts: [String] = []
        var absences: [String] = []

        if let unit {
            anchors.append("autonomo: \(unit.name)")
            facts.append("carta: \(unit.charter)")
            // WAVE-030: never claim local catalog pause is the server loop.
            facts.append(
                unit.paused
                    ? "catalogo_local: pausado no iPhone (≠ loop servidor)"
                    : "catalogo_local: no iPhone"
            )
            facts.append("idade_local: \(unit.ageLabel)")
        } else {
            absences.append("lista de Autônomos — nenhum aberto")
        }

        let subjects = AutonomosDecisionJudgment.packSubjects(from: backlog)
        let decisionCount = AutonomosDecisionJudgment.decisionCount(from: backlog)

        let loop = AutonomosRunControlJudgment.packLoopFacts(
            face: controlFace,
            canControl: canControl,
            live: live,
            receipt: lastControlReceipt
        )
        facts.append(contentsOf: loop.facts)
        absences.append(contentsOf: loop.absences)
        anchors.append("loop · \(controlFace.productWord)")

        // WAVE-065: multi-area bind honesty.
        if !areas.isEmpty || selectedAreaID != nil {
            let bind = AutonomosAreaBindJudgment.packFacts(
                areas: areas,
                selectedAreaID: selectedAreaID
            )
            facts.append(contentsOf: bind.facts)
            absences.append(contentsOf: bind.absences)
        }

        // WAVE-035: transfer handoff honesty.
        let transfer = AutonomosTransferJudgment.packFacts(
            canTransfer: AutonomosTransferJudgment.canTransfer(canControlSelectedArea: canControl),
            receipt: lastTransferReceipt
        )
        facts.append(contentsOf: transfer.facts)
        absences.append(contentsOf: transfer.absences)

        // WAVE-036: task health / incident honesty.
        let health = AutonomosTaskHealthJudgment.packFacts(
            areaSelected: areaSelected,
            health: taskHealth
        )
        facts.append(contentsOf: health.facts)
        absences.append(contentsOf: health.absences)
        if AutonomosTaskHealthJudgment.incidentPresent(taskHealth) {
            anchors.append("incident · present")
        }

        // WAVE-037: global fleet snapshot honesty.
        let fleetPack = AutonomosFleetJudgment.packFacts(fleet)
        facts.append(contentsOf: fleetPack.facts)
        absences.append(contentsOf: fleetPack.absences)

        // WAVE-038: scheduled digest window honesty.
        let digestPack = AutonomosDigestJudgment.packFacts(digest)
        facts.append(contentsOf: digestPack.facts)
        absences.append(contentsOf: digestPack.absences)

        if let destination {
            facts.append("tela: \(destination.navTitle)")
            anchors.append("dest: \(destination.navTitle)")
            switch destination {
            case .hub:
                facts.append("foco: hub do Autônomo — saúde e atalhos locais")
                if decisionCount > 0 {
                    facts.append("decisoes_publicadas: \(decisionCount)")
                    for title in subjects {
                        facts.append("decisao: \(title)")
                    }
                }
            case .decisions, .decisionInbox, .decisionOrder:
                facts.append("foco: decisões")
                if decisionCount > 0 {
                    facts.append("decisoes_publicadas: \(decisionCount)")
                    for title in subjects {
                        facts.append("decisao: \(title)")
                        anchors.append("decision:\(title)")
                    }
                } else if backlog == nil {
                    absences.append("backlog de decisões não hidratado — não invente inbox")
                } else {
                    absences.append("zero itens com decisionRequired / operatorDecisionRequired")
                }
            case .evolution:
                facts.append("foco: evolução")
                let evo = AutonomosEvolutionJudgment.packFacts(
                    marcos: AutonomosEvolutionJudgment.marcos(delivered: delivered, cycles: cycles)
                )
                facts.append(contentsOf: evo.facts)
                absences.append(contentsOf: evo.absences)
            case .moment:
                facts.append("foco: digest/momento — janela provider-safe")
            case .incident:
                facts.append("foco: incidente — só sinais reais da face")
                // health pack facts already appended above
            }
        } else {
            facts.append("tela: catálogo do operador")
        }

        absences.append("create no servidor ainda pendente (§5)")
        absences.append("catálogo local some se o app for morto — não invente frota 24/7 persistida")
        absences.append("NL de chat ainda não autoriza tools de escrita no wire")

        let subject: String
        if decisionCount > 0, let first = subjects.first {
            subject = unit.map { "Autônomo · \($0.name) · \(first)" }
                ?? "decisões · \(first)"
        } else {
            subject = unit.map { "Autônomo · \($0.name)" } ?? "catálogo Autônomos"
        }

        return AgenticOccasionPack(
            surface: "autonomos",
            subject: subject,
            anchors: anchors,
            facts: facts,
            absences: absences,
            canDo: .faceCTALocal
        ).render()
    }
}
