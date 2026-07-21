import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive finished-turn proof face (WAVE-042).
enum ExecutionProofFace: Equatable {
    case empty
    case steps(Int)
    case decision
    case quality(score: Double, status: String)
    case evidence(Int)
    /// Multiple organs present — lead by strongest signal.
    case compound(lead: String, parts: [String])

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .steps: return "steps"
        case .decision: return "decision"
        case .quality: return "quality"
        case .evidence: return "evidence"
        case .compound: return "compound"
        }
    }

    /// Collapsed header kicker — never always "Obra concluída".
    var kicker: String {
        switch self {
        case .empty: return "Prova"
        case .steps: return "Obra com passos"
        case .decision: return "Decisão do atlas"
        case .quality: return "Qualidade da obra"
        case .evidence: return "Evidência publicada"
        case .compound(let lead, _): return lead
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "sem prova publicada"
        case .steps(let n):
            return n == 1 ? "prova com 1 passo" : "prova com \(n) passos"
        case .decision:
            return "prova com decisão do atlas"
        case .quality(let score, let status):
            return "prova de qualidade \(String(format: "%.1f", score)), status \(status)"
        case .evidence(let n):
            return n == 1 ? "prova com 1 artefato" : "prova com \(n) artefatos"
        case .compound(_, let parts):
            return "prova composta, " + parts.joined(separator: ", ")
        }
    }
}

// MARK: - Judgment

/// Pure execution proof grammar — face · gates · summary · pack · spoken.
enum ExecutionProofJudgment {

    static func hasDecisionSurface(_ d: AtlasDecisionSummary) -> Bool {
        d.selectedProvider != nil
            || d.selectedModel != nil
            || d.reason != nil
            || d.confidenceScore != nil
            || d.riskLevel != nil
            || d.routeMode != nil
            || d.wasOverridden
    }

    static func shouldDisplay(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item] = []
    ) -> Bool {
        !bubble.activities.isEmpty
            || bubble.decisionSummary.map(hasDecisionSurface) == true
            || bubble.qualitySummary != nil
            || (!artifactItems.isEmpty && bubble.traceId != nil)
    }

    static func face(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item] = []
    ) -> ExecutionProofFace {
        guard shouldDisplay(bubble: bubble, artifactItems: artifactItems) else {
            return .empty
        }

        var parts: [String] = []
        var lead = "Prova da obra"

        let steps = bubble.activities.count
        if steps > 0 {
            parts.append(steps == 1 ? "1 passo" : "\(steps) passos")
            lead = "Obra com passos"
        }
        if let d = bubble.decisionSummary, hasDecisionSurface(d) {
            parts.append("decisão")
            lead = "Decisão do atlas"
        }
        if let q = bubble.qualitySummary {
            parts.append("quality \(String(format: "%.1f", q.score))")
            lead = "Qualidade da obra"
        }
        if !artifactItems.isEmpty {
            parts.append(artifactItems.count == 1 ? "1 artefato" : "\(artifactItems.count) artefatos")
            if steps == 0, bubble.decisionSummary.map(hasDecisionSurface) != true,
               bubble.qualitySummary == nil {
                lead = "Evidência publicada"
            }
        }

        if parts.count >= 2 {
            return .compound(lead: lead, parts: parts)
        }
        if steps > 0 { return .steps(steps) }
        if let d = bubble.decisionSummary, hasDecisionSurface(d) { return .decision }
        if let q = bubble.qualitySummary {
            return .quality(score: q.score, status: q.status)
        }
        if !artifactItems.isEmpty { return .evidence(artifactItems.count) }
        return .empty
    }

    static func summaryLine(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item] = [],
        humanDuration: (Int) -> String
    ) -> String {
        var parts: [String] = []
        if !bubble.activities.isEmpty {
            parts.append("\(bubble.activities.count) passos")
        }
        if let ms = bubble.elapsedMs, ms > 0 {
            parts.append(humanDuration(ms))
        }
        if let q = bubble.qualitySummary {
            parts.append("quality \(String(format: "%.1f", q.score))")
        }
        if !artifactItems.isEmpty {
            parts.append("\(artifactItems.count) artefatos")
        }
        if let d = bubble.decisionSummary, hasDecisionSurface(d) {
            if let mode = d.routeMode { parts.append(mode) }
            else { parts.append("decisão") }
        }
        return parts.joined(separator: " · ")
    }

    static func rankedArtifacts(
        _ items: [AtlasTraceArtifacts.Item]
    ) -> [AtlasTraceArtifacts.Item] {
        ArtifactJudgment.rankItems(items)
    }

    static func spokenCollapsed(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item],
        expanded: Bool,
        humanDuration: (Int) -> String
    ) -> String {
        let face = face(bubble: bubble, artifactItems: artifactItems)
        var parts = [
            "prova da execução",
            expanded ? "expandida" : "recolhida",
            face.spokenFace
        ]
        if let ms = bubble.elapsedMs, ms > 0 {
            parts.append(humanDuration(ms))
        }
        return parts.joined(separator: ", ")
    }

    static func packFacts(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item] = []
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(bubble: bubble, artifactItems: artifactItems)
        facts.append("proof_face: \(face.productWord)")
        if !shouldDisplay(bubble: bubble, artifactItems: artifactItems) {
            absences.append("nenhuma prova publicada neste turno")
            return (facts, absences)
        }
        if !bubble.activities.isEmpty {
            facts.append("steps: \(bubble.activities.count)")
        } else {
            absences.append("sem passos de atividade")
        }
        if let d = bubble.decisionSummary, hasDecisionSurface(d) {
            if let p = d.selectedProvider { facts.append("decision_provider: \(p)") }
            if let m = d.routeMode { facts.append("decision_mode: \(m)") }
            if let c = d.confidenceScore {
                facts.append("decision_confidence: \(String(format: "%.2f", c))")
            }
        } else {
            absences.append("sem decisão de atlas publicada")
        }
        if let q = bubble.qualitySummary {
            facts.append("quality_score: \(String(format: "%.2f", q.score))")
            facts.append("quality_status: \(q.status)")
        } else {
            absences.append("sem quality summary")
        }
        if artifactItems.isEmpty {
            absences.append("sem artefatos na prova")
        } else {
            facts.append("artifacts: \(artifactItems.count)")
            for item in rankedArtifacts(artifactItems).prefix(4) {
                facts.append("artifact: \(item.kind.rawValue) · \(item.name)")
            }
        }
        return (facts, absences)
    }
}
