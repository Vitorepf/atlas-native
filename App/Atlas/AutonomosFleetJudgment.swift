import Foundation
import AtlasCore

// MARK: - Fleet judgment (WAVE-037)

enum AutonomosFleetFace: Equatable {
    case absent
    case quiet
    case live(Int)
    case attention(Int)

    var productWord: String {
        switch self {
        case .absent: return "absent"
        case .quiet: return "quiet"
        case .live: return "live"
        case .attention: return "attention"
        }
    }

    var spokenFace: String {
        switch self {
        case .absent: return "frota não publicada"
        case .quiet: return "frota quieta"
        case .live(let n):
            return n == 1 ? "1 agente vivo" : "\(n) agentes vivos"
        case .attention(let n):
            return n == 1 ? "1 agente pede atenção" : "\(n) agentes pedem atenção"
        }
    }

    var kicker: String {
        switch self {
        case .absent: return "Frota"
        case .quiet: return "Frota quieta"
        case .live: return "Frota viva"
        case .attention: return "Frota pede atenção"
        }
    }
}

enum AutonomosFleetJudgment {

    /// Attention: alive but not authorized, or desired but not alive.
    static func needsAttention(_ agent: AtlasAutonomosFleetAgent) -> Bool {
        if agent.alive && !agent.authorized { return true }
        if agent.desired && !agent.alive { return true }
        return false
    }

    /// Alive first → attention → wire order.
    static func rank(_ agents: [AtlasAutonomosFleetAgent]) -> [AtlasAutonomosFleetAgent] {
        agents.enumerated().sorted { lhs, rhs in
            let la = lhs.element.alive
            let ra = rhs.element.alive
            if la != ra { return la && !ra }
            let lAtt = needsAttention(lhs.element)
            let rAtt = needsAttention(rhs.element)
            if lAtt != rAtt { return lAtt && !rAtt }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    static func face(from fleet: AtlasAutonomosFleetResponse?) -> AutonomosFleetFace {
        guard let fleet else { return .absent }
        let agents = fleet.agents
        if agents.isEmpty && fleet.activeCount == 0 { return .quiet }
        let attention = agents.filter(needsAttention).count
        if attention > 0 { return .attention(attention) }
        let alive = agents.filter(\.alive).count
        if alive > 0 { return .live(alive) }
        // Published but none alive — quiet honesty (not invent failure).
        return .quiet
    }

    static func summaryLine(_ fleet: AtlasAutonomosFleetResponse) -> String {
        let alive = fleet.agents.filter(\.alive).count
        let attention = fleet.agents.filter(needsAttention).count
        var parts = ["ativos \(fleet.activeCount)", "vivos \(alive)"]
        if attention > 0 { parts.append("atenção \(attention)") }
        if !fleet.spendingAccounts.isEmpty {
            parts.append("contas \(fleet.spendingAccounts.count)")
        }
        return parts.joined(separator: " · ")
    }

    static func agentMeta(_ agent: AtlasAutonomosFleetAgent) -> String {
        var parts: [String] = [agent.status]
        if agent.alive { parts.append("vivo") }
        if !agent.authorized { parts.append("não autorizado") }
        if agent.desired && !agent.alive { parts.append("desejado") }
        if let up = agent.uptimeSeconds, up > 0 {
            parts.append("up \(up)s")
        }
        return parts.joined(separator: " · ")
    }

    static func spokenAgent(_ agent: AtlasAutonomosFleetAgent) -> String {
        "\(agent.label), \(agentMeta(agent))"
    }

    static func packFacts(_ fleet: AtlasAutonomosFleetResponse?) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(from: fleet)
        facts.append("fleet_face: \(face.productWord)")
        guard let fleet else {
            absences.append("frota global não hidratada neste recorte")
            return (facts, absences)
        }
        facts.append("fleet_master: \(fleet.fleetMaster)")
        facts.append("active_count: \(fleet.activeCount)")
        facts.append("agents: \(fleet.agents.count)")
        facts.append(summaryLine(fleet))
        for a in rank(fleet.agents).prefix(6) {
            facts.append("agent: \(a.label) · \(agentMeta(a))")
        }
        if fleet.agents.isEmpty {
            absences.append("lista de agentes vazia no snapshot publicado")
        }
        absences.append("casca não inventa set/unset de frota — só lê snapshot")
        return (facts, absences)
    }

    /// History tail — last events, silence if empty.
    static func recentEvents(
        _ history: AtlasAutonomosFleetHistoryResponse?,
        limit: Int = 5
    ) -> [AtlasAutonomosFleetHistoryEvent] {
        guard let history else { return [] }
        return Array(history.events.suffix(limit).reversed())
    }
}
