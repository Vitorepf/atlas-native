import Foundation
import AtlasCore

/// Spoken event — peel de AutonomosFleetHistory+A11y.
/// Identity → AutonomosFleetHistory+A11yEvent+Identity.swift
/// Detail → AutonomosFleetHistory+A11yEvent+Detail.swift

enum AutonomosFleetHistoryA11yEvent {
    static func spokenEvent(_ event: AtlasAutonomosFleetHistoryEvent, index: Int, visible: Int) -> String {
        (
            AutonomosFleetHistoryA11yEventIdentity.spokenIdentity(event, index: index, visible: visible)
            + AutonomosFleetHistoryA11yEventDetail.spokenDetail(event, index: index)
        ).joined(separator: ", ")
    }
}
