import Foundation
import AtlasCore

/// Spoken labels do histórico da frota — peel de AutonomosFleetHistorySection (CICLO C).
/// Contagem visível vs total publicada; evento fala só campos do payload.
/// Event → AutonomosFleetHistory+A11yEvent.swift
/// Section → AutonomosFleetHistory+A11ySection.swift

enum AutonomosFleetHistoryA11y {
    static let visibleCap = AutonomosFleetHistoryA11ySection.visibleCap

    static func spokenSection(total: Int) -> String {
        AutonomosFleetHistoryA11ySection.spokenSection(total: total)
    }

    static func spokenEvent(_ event: AtlasAutonomosFleetHistoryEvent, index: Int, visible: Int) -> String {
        AutonomosFleetHistoryA11yEvent.spokenEvent(event, index: index, visible: visible)
    }
}
