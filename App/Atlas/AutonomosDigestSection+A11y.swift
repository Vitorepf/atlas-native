import Foundation
import AtlasCore

/// Spoken labels do digest governado — peel de AutonomosDigestSection (CICLO C).
/// Agrega só contagens e textos publicados; silêncio/sem portão quando delivered>0.
/// Counts → AutonomosDigestSection+A11yCounts.swift

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
}
