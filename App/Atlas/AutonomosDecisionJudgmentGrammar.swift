import Foundation
import AtlasCore

// WAVE-137 DecisionJudgment grammar + face chrome spoken

extension AutonomosDecisionJudgment {
    // MARK: Grammar / product words

    static func primaryCTATitle(count: Int) -> String {
        count == 1 ? "Ver 1 decisão" : "Ver \(count) decisões"
    }

    static func rowMeta(_ item: AutonomosDecisionItem) -> String {
        let risk = item.riskLevel.trimmingCharacters(in: .whitespacesAndNewlines)
        let route = item.route.trimmingCharacters(in: .whitespacesAndNewlines)
        var parts: [String] = []
        if !risk.isEmpty { parts.append(risk) }
        if !route.isEmpty { parts.append(route) }
        switch item.kind {
        case .inbox: parts.append("inbox")
        case .workOrder: parts.append("ordem")
        }
        return parts.joined(separator: " · ")
    }

    static func spokenItem(_ item: AutonomosDecisionItem) -> String {
        "\(item.title), \(rowMeta(item))"
    }

    /// Map published option strings + defaults to operator decisions.
    static func allowedDecisions(for item: AutonomosDecisionItem) -> [AtlasAutonomosOperatorDecision] {
        let raw = item.decisionOptions
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
        if raw.isEmpty {
            return [.accept, .reject, .deferDecision, .requestChanges]
        }
        var seen = Set<AtlasAutonomosOperatorDecision>()
        var out: [AtlasAutonomosOperatorDecision] = []
        for token in raw {
            let decision: AtlasAutonomosOperatorDecision?
            switch token {
            case "accept", "aceitar", "approve", "aprovar":
                decision = .accept
            case "reject", "rejeitar", "deny":
                decision = .reject
            case "defer", "adiar", "later":
                decision = .deferDecision
            case "request_changes", "request-changes", "changes", "pedir_mudancas", "pedir mudanças":
                decision = .requestChanges
            default:
                decision = AtlasAutonomosOperatorDecision(rawValue: token)
            }
            if let decision, seen.insert(decision).inserted {
                out.append(decision)
            }
        }
        return out.isEmpty ? [.accept, .reject, .deferDecision, .requestChanges] : out
    }

    static func decisionLabel(_ decision: AtlasAutonomosOperatorDecision) -> String {
        switch decision {
        case .accept: return "Aceitar"
        case .reject: return "Rejeitar"
        case .deferDecision: return "Adiar"
        case .requestChanges: return "Pedir mudanças"
        }
    }

    static func riskLevel(from raw: String) -> AtlasAutonomosRiskLevel {
        switch raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "low", "baixo": return .low
        case "high", "alto": return .high
        case "critical", "crítico", "critico": return .critical
        default: return .medium
        }
    }

    /// Mirror of Core high/critical accept rule (internal on Core enum — casca copy).
    static func riskRequiresRationale(_ risk: AtlasAutonomosRiskLevel) -> Bool {
        risk == .high || risk == .critical
    }

    /// Pack subjects = real decision titles (limit).
    static func packSubjects(
        from backlog: AtlasAutonomosBacklogResponse?,
        limit: Int = 5
    ) -> [String] {
        items(from: backlog).prefix(limit).map(\.title)
    }

    // MARK: Face chrome spoken (WAVE-104)

    static func spokenFaceChrome(_ face: AutonomosDecisionFace) -> String {
        "\(face.spokenFace). \(face.heroSub)"
    }


}
