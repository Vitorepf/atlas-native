import Foundation
import AtlasCore

/// Spoken labels do digest governado — peel de AutonomosDigestSection (CICLO C).
/// Agrega só contagens e textos publicados; silêncio/sem portão quando delivered>0.
/// Counts → AutonomosDigestSection+A11yCounts.swift
/// Last → AutonomosDigestSection+A11yLast.swift

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
            AutonomosDigestSectionA11yLast.appendLastBody(
                &parts,
                windowCaption: windowCaption,
                counts: counts,
                mergeHash: mergeHash,
                riskHeadline: riskHeadline,
                decisionTitle: decisionTitle
            )
        } else if let reason = scheduleReason?.nonEmpty {
            parts.append(reason)
        } else if nextDigestAt?.nonEmpty == nil {
            parts.append("sem agenda publicada")
        }
        return parts.joined(separator: ", ")
    }
}
