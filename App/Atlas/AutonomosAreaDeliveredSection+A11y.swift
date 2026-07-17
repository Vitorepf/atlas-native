import Foundation
import AtlasCore

/// Spoken labels das entregas comprovadas — peel de AutonomosAreaDeliveredSection (CICLO C).
/// Merge só quando `mergePerformed` e hash publicados; nunca «melhorou» fabricado.
/// Caption/hint → AutonomosAreaDeliveredSection+A11yCaption.swift
/// Row → AutonomosAreaDeliveredSection+A11yRow.swift

enum AutonomosAreaDeliveredA11y {
    static let visibleCap = 3

    static func spokenSection(isSelf: Bool, total: Int, visible: Int) -> String {
        if isSelf {
            return AutonomosAreaDeliveredA11ySelf.spokenSection(total: total, visible: visible)
        }
        if visible < total {
            return "entregas comprovadas, \(visible) de \(total) merges recentes"
        }
        return "entregas comprovadas, \(total) merge\(total == 1 ? "" : "s")"
    }

    static func spokenEmptySelf() -> String {
        AutonomosAreaDeliveredA11yEmpty.spokenEmptySelf()
    }
}
