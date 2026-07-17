import SwiftUI
import AtlasCore

/// M139 — decisões públicas pendentes; silêncio total quando count = 0.
/// Spoken → +A11y · chips → +Chips · nightly → +Blocks · Header → +Header.
/// Predicates → +Predicates.swift · Chrome → +Chrome.swift
struct AutonomosAwaitingYouSection: View {
    let backlog: AtlasAutonomosBacklogResponse?
    let onOpenDetail: (AutonomosDetailSheet) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        if decisionCount > 0 {
            awaitingChrome
                .accessibilityElement(children: .contain)
                .accessibilityLabel(sectionSpokenLabel)
                .accessibilityHint("abre inbox ou ordens com decisão pública pendente")
                .accessibilityIdentifier(A11yID.autonomosAwaitingYou)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
                .animation(reduceMotion ? nil : AtlasMotion.editorial, value: decisionCount)
        }
    }
}
