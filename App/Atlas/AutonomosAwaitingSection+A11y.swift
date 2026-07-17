import Foundation
import AtlasCore

/// Spoken labels — peel de AutonomosAwaitingYouSection (régua ≤100).
/// Count → AutonomosAwaitingSection+A11yCount.swift

extension AutonomosAwaitingYouSection {
    var sectionSpokenLabel: String {
        if decisionCount == 1 {
            return "aguardando você, 1 decisão pendente"
        }
        return "aguardando você, \(decisionCount) decisões pendentes"
    }

    func inboxSpokenLabel(count: Int) -> String {
        count == 1
            ? "abrir 1 decisão de inbox pendente"
            : "abrir \(count) decisões de inbox pendentes"
    }

    func workOrdersSpokenLabel(count: Int) -> String {
        count == 1
            ? "abrir 1 ordem aguardando sua decisão"
            : "abrir \(count) ordens aguardando sua decisão"
    }
}
