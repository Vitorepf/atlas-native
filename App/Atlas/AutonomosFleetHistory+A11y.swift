import Foundation
import AtlasCore

/// Spoken labels do histórico da frota — peel de AutonomosFleetHistorySection (CICLO C).
/// Contagem visível vs total publicada; evento fala só campos do payload.
/// Event → AutonomosFleetHistory+A11yEvent.swift

enum AutonomosFleetHistoryA11y {
    static let visibleCap = 6

    static func spokenSection(total: Int) -> String {
        guard total > 0 else { return "histórico da frota vazio" }
        if total > visibleCap {
            return "histórico da frota, \(visibleCap) de \(total) eventos recentes"
        }
        return "histórico da frota, \(total) evento\(total == 1 ? "" : "s")"
    }

    static func spokenEvent(_ event: AtlasAutonomosFleetHistoryEvent, index: Int, visible: Int) -> String {
        AutonomosFleetHistoryA11yEvent.spokenEvent(event, index: index, visible: visible)
    }
}
