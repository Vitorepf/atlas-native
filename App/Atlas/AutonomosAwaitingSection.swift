import SwiftUI
import AtlasCore

/// M139 — decisões públicas pendentes; silêncio total quando count = 0.
/// Spoken → +A11y · chips → +Chips · nightly → +Blocks · Header → +Header.
/// Predicates → +Predicates.swift · Chrome → +Chrome.swift
/// A11y → +A11yShell.swift
struct AutonomosAwaitingYouSection: View {
    let backlog: AtlasAutonomosBacklogResponse?
    let onOpenDetail: (AutonomosDetailSheet) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        if decisionCount > 0 {
            awaitingA11y
        }
    }
}
