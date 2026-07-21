import Foundation
import AtlasCore

import SwiftUI
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

// MARK: - Strip chrome

// MARK: - Thin fleet strip on Autônomos catalog (WAVE-037)

/// One domain: published global fleet snapshot — not a monólito map.
struct AutonomosFleetStrip: View {
    let fleet: AtlasAutonomosFleetResponse
    var history: AtlasAutonomosFleetHistoryResponse? = nil

    private var face: AutonomosFleetFace {
        AutonomosFleetJudgment.face(from: fleet)
    }

    private var agents: [AtlasAutonomosFleetAgent] {
        AutonomosFleetJudgment.rank(fleet.agents)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                AutonomosMapChrome.kicker(
                    face.kicker,
                    live: face.productWord == "live" || face.productWord == "attention"
                )
                Spacer(minLength: 0)
                Text(AutonomosFleetJudgment.summaryLine(fleet))
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
            }

            if agents.isEmpty {
                Text("Snapshot publicado sem agentes neste recorte.")
                    .font(AtlasFont.serifItalic(13))
                    .foregroundStyle(AtlasTheme.textTertiary)
            } else {
                ForEach(agents.prefix(6)) { agent in
                    agentRow(agent)
                }
                if agents.count > 6 {
                    Text("+\(agents.count - 6) agentes no snapshot")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
            }

            let events = AutonomosFleetJudgment.recentEvents(history, limit: 3)
            if !events.isEmpty {
                Text("Histórico")
                    .font(AtlasFont.mono(10))
                    .tracking(0.8)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.top, 4)
                ForEach(events) { event in
                    Text("\(event.event) · \(event.agentKey) · \(event.at)")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.vertical, 12)
        .background(AtlasTheme.surface.opacity(0.35))
        .accessibilityElement(children: .contain)
        .accessibilityLabel(face.spokenFace)
        .accessibilityIdentifier(A11yID.autonomosFleetMap)
    }

    private func agentRow(_ agent: AtlasAutonomosFleetAgent) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Circle()
                .fill(agent.alive ? AtlasTheme.accent.opacity(0.9) : AtlasTheme.textTertiary.opacity(0.5))
                .frame(width: 6, height: 6)
                .padding(.top, 5)
            VStack(alignment: .leading, spacing: 2) {
                Text(agent.label)
                    .font(AtlasFont.serif(15, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(1)
                Text(AutonomosFleetJudgment.agentMeta(agent))
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(
                        AutonomosFleetJudgment.needsAttention(agent)
                            ? AtlasTheme.domOperacional
                            : AtlasTheme.textTertiary
                    )
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AutonomosFleetJudgment.spokenAgent(agent))
    }
}
