import Foundation
import AtlasCore

/// Spoken labels do digest governado — peel de AutonomosDigestSection (CICLO C).
/// Agrega só contagens e textos publicados; silêncio/sem portão quando delivered>0.
/// Counts → AutonomosDigestSection+A11yCounts.swift
/// Last → AutonomosDigestSection+A11yLast.swift
/// Schedule → AutonomosDigestSection+A11ySchedule.swift

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
        var parts = spokenScheduleLead(
            nextDigestAt: nextDigestAt,
            scheduleReason: scheduleReason,
            hasLast: hasLast
        )
        if hasLast {
            AutonomosDigestSectionA11yLast.appendLastBody(
                &parts,
                windowCaption: windowCaption,
                counts: counts,
                mergeHash: mergeHash,
                riskHeadline: riskHeadline,
                decisionTitle: decisionTitle
            )
        }
        return parts.joined(separator: ", ")
    }
}
