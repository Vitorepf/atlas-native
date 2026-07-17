import Foundation
import AtlasCore

// Row spoken — peel de AutonomosAreaDeliveredA11y.
// Merge → AutonomosAreaDeliveredSection+A11yRow+Merge.swift
// Open → AutonomosAreaDeliveredSection+A11yRow+Open.swift

extension AutonomosAreaDeliveredA11y {
    static func spokenRow(
        _ cycle: AtlasAutonomosCycle,
        index: Int,
        visible: Int,
        isSelf: Bool,
        opensGraph: Bool
    ) -> String {
        spokenRowOpenParts(cycle, index: index, visible: visible, isSelf: isSelf, opensGraph: opensGraph)
            .joined(separator: ", ")
    }
}
