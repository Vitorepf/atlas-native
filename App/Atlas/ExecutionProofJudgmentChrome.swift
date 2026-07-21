import Foundation
import AtlasCore
import SwiftUI

// WAVE-144 ExecutionProofJudgment chrome spoken

extension ExecutionProofJudgment {
    // MARK: - WAVE-082 quality · activity · replay absence

    static func qualityLineFlags(_ q: AtlasQualitySummary, base: String) -> String {
        var out = base
        if q.flagCount > 0 { out += " · \(q.flagCount) alertas" }
        if q.actionCount > 0 { out += " · \(q.actionCount) ações" }
        return out
    }

    static func qualityLine(_ q: AtlasQualitySummary) -> String {
        let base = "quality \(String(format: "%.1f", q.score)) · \(q.status)"
        return qualityLineFlags(q, base: base)
    }

    static func qualitySpoken(_ q: AtlasQualitySummary) -> String {
        var parts = ["qualidade \(String(format: "%.1f", q.score)), status \(q.status)"]
        if q.flagCount > 0 { parts.append("\(q.flagCount) alertas") }
        if q.actionCount > 0 { parts.append("\(q.actionCount) ações de correção") }
        return parts.joined(separator: ", ")
    }

    static func activitySpoken(_ act: AtlasAgentActivity) -> String {
        var parts = [act.title]
        if let d = act.detail, !d.isEmpty { parts.append(d) }
        return parts.joined(separator: ", ")
    }

    static let replayUnavailableLabel =
        "REPLAY indisponível · eventos sem timestamps"
    static let replayUnavailableSpoken =
        "replay indisponível porque os eventos não têm timestamps"

    // MARK: Chrome spoken (WAVE residual · proof card)

    static let artifactsHint = "abre a lista de artefatos deste trace"
    static let replayScrubberLabel = "scrubber de replay da execução"

    static func spokenArtifactsCTA(count: Int) -> String {
        let noun = count == 1 ? "artefato" : "artefatos"
        return "artefatos desta execução, \(count) \(noun)"
    }

    static func spokenReason(_ reason: String) -> String {
        "motivo, \(reason)"
    }

    static func spokenReplayStep(index: Int, total: Int) -> String {
        let step = min(max(0, index), max(0, total - 1)) + 1
        return "replay da execução, passo \(step) de \(total)"
    }

    static func spokenReplayValue(index: Int, total: Int) -> String {
        let step = min(max(0, index), max(0, total - 1)) + 1
        return "passo \(step) de \(total)"
    }

    static func qualityPackFacts(
        _ q: AtlasQualitySummary
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        let absences: [String] = []
        facts.append("quality_score: \(String(format: "%.2f", q.score))")
        facts.append("quality_status: \(q.status)")
        if q.flagCount > 0 { facts.append("quality_flags: \(q.flagCount)") }
        if q.actionCount > 0 { facts.append("quality_actions: \(q.actionCount)") }
        return (facts, absences)
    }

}
