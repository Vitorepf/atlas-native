import Foundation
import AtlasCore

/// Spoken labels — peel de AutonomosAwaitingYouSection (régua ≤100).
/// Count → AutonomosAwaitingSection+A11yCount.swift
/// Inbox → AutonomosAwaitingSection+A11yInbox.swift · Orders → +A11yWorkOrders.swift

extension AutonomosAwaitingYouSection {
    var sectionSpokenLabel: String {
        if decisionCount == 1 {
            return "aguardando você, 1 decisão pendente"
        }
        return "aguardando você, \(decisionCount) decisões pendentes"
    }
}
