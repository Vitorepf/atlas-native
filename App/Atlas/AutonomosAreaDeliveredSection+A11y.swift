import Foundation
import AtlasCore

/// Spoken labels das entregas comprovadas — peel de AutonomosAreaDeliveredSection (CICLO C).
/// Merge só quando `mergePerformed` e hash publicados; nunca «melhorou» fabricado.
/// Caption/hint → AutonomosAreaDeliveredSection+A11yCaption.swift
/// Row → AutonomosAreaDeliveredSection+A11yRow.swift
/// Peer → AutonomosAreaDeliveredSection+A11yPeer.swift

enum AutonomosAreaDeliveredA11y {
    static let visibleCap = 3

    static func spokenSection(isSelf: Bool, total: Int, visible: Int) -> String {
        if isSelf {
            return AutonomosAreaDeliveredA11ySelf.spokenSection(total: total, visible: visible)
        }
        return spokenPeerSection(total: total, visible: visible)
    }

    static func spokenEmptySelf() -> String {
        AutonomosAreaDeliveredA11yEmpty.spokenEmptySelf()
    }
}
