import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive multi-agent lanes face (WAVE-049).
enum ConversationAgentLanesFace: Equatable {
    case empty
    case single
    case multi(Int)
    case attention(Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .single: return "single"
        case .multi: return "multi"
        case .attention: return "attention"
        }
    }

    var kicker: String? {
        switch self {
        case .empty, .single: return nil
        case .multi: return "LANES"
        case .attention: return "LANES · ATENÇÃO"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "sem agentes na execução"
        case .single:
            return "1 agente na execução"
        case .multi(let n):
            return "\(n) agentes nas lanes"
        case .attention(let n):
            return n == 1
                ? "1 lane pede atenção"
                : "\(n) lanes pedem atenção"
        }
    }
}

// MARK: - Judgment

/// Pure agent-lanes grammar — rank · face · pack · spoken.
/// Attention: failed → awaiting → running → done (wire-stable).
enum ConversationAgentLanesJudgment {

    /// Lower = higher attention.
    static func statusRank(_ status: String) -> Int {
        switch AtlasTurnStatus(rawValue: status) {
        case .failed: return 0
        case .cancelled: return 1
        case .awaitingUserChoice: return 2
        case .awaitingExternal: return 3
        case .processing: return 4
        case .queued: return 5
        case .succeeded: return 6
        case .unknown: return 7
        }
    }

    static func needsAttention(_ agent: ExecAgent) -> Bool {
        switch AtlasTurnStatus(rawValue: agent.status) {
        case .failed, .cancelled, .awaitingUserChoice, .awaitingExternal:
            return true
        default:
            return false
        }
    }

    static func rank(_ agents: [ExecAgent]) -> [ExecAgent] {
        agents.enumerated().sorted { lhs, rhs in
            let lr = statusRank(lhs.element.status)
            let rr = statusRank(rhs.element.status)
            if lr != rr { return lr < rr }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    static func face(from agents: [ExecAgent]) -> ConversationAgentLanesFace {
        if agents.isEmpty { return .empty }
        let attention = agents.filter(needsAttention).count
        if attention > 0 { return .attention(attention) }
        if agents.count == 1 { return .single }
        return .multi(agents.count)
    }

    static func label(for agent: ExecAgent) -> String {
        agent.agent ?? providerWord(agent.provider)
    }

    static func providerWord(_ provider: String?) -> String {
        guard let provider, !provider.isEmpty else { return "agente" }
        return provider
            .replacingOccurrences(of: "_cli", with: "")
            .replacingOccurrences(of: "_", with: " ")
    }

    static func packFacts(from agents: [ExecAgent]) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(from: agents)
        facts.append("agent_lanes_face: \(face.productWord)")
        if agents.isEmpty {
            absences.append("nenhum agente publicado neste turno")
            return (facts, absences)
        }
        facts.append("agents: \(agents.count)")
        for a in rank(agents).prefix(6) {
            facts.append("agent: \(label(for: a)) · \(a.status)")
        }
        let attention = agents.filter(needsAttention).count
        if attention > 0 {
            facts.append("lanes_attention: \(attention)")
        }
        return (facts, absences)
    }

    static func spokenSection(from agents: [ExecAgent]) -> String {
        face(from: agents).spokenFace
    }
}
