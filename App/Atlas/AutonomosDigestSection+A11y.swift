import Foundation
import AtlasCore

/// Spoken labels do digest governado — peel de AutonomosDigestSection (CICLO C).
/// Agrega só contagens e textos publicados; silêncio/sem portão quando delivered>0.

enum AutonomosDigestSectionA11y {
    static func spokenSection(
        nextDigestAt: String?,
        scheduleReason: String?,
        hasLast: Bool,
        windowCaption: String?,
        counts: AtlasAutonomosDigestCounts,
        mergeHash: String?,
        riskHeadline: String?,
        decisionTitle: String?
    ) -> String {
        var parts: [String] = []
        if let next = nextDigestAt?.nonEmpty {
            parts.append("próximo resumo, agendado para \(next)")
        } else {
            parts.append("resumo governado")
        }
        if hasLast {
            if let windowCaption { parts.append(windowCaption) }
            appendCounts(&parts, counts: counts)
            if let mergeHash { parts.append("merge \(mergeHash)") }
            if let riskHeadline { parts.append(riskHeadline) }
            if let decisionTitle { parts.append(decisionTitle) }
            if counts.delivered > 0 && counts.risks == 0 && counts.pendingDecisions == 0 {
                parts.append("silêncio, segue sem portão")
            }
        } else if let reason = scheduleReason?.nonEmpty {
            parts.append(reason)
        } else if nextDigestAt?.nonEmpty == nil {
            parts.append("sem agenda publicada")
        }
        return parts.joined(separator: ", ")
    }

    private static func appendCounts(_ parts: inout [String], counts: AtlasAutonomosDigestCounts) {
        if counts.delivered > 0 {
            parts.append("\(counts.delivered) entrega\(counts.delivered == 1 ? "" : "s") comprovada\(counts.delivered == 1 ? "" : "s")")
        }
        if counts.risks > 0 {
            parts.append("\(counts.risks) risco\(counts.risks == 1 ? "" : "s")")
        }
        if counts.pendingDecisions > 0 {
            parts.append("\(counts.pendingDecisions) decisão\(counts.pendingDecisions == 1 ? "" : "ões") pendente\(counts.pendingDecisions == 1 ? "" : "s")")
        }
    }
}
