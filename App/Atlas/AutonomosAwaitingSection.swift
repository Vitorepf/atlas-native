import SwiftUI
import AtlasCore

/// M139 — decisões públicas pendentes; silêncio total quando count = 0.
/// Spoken → +A11y · chips → +Chips · nightly → +Blocks · Header → +Header.
struct AutonomosAwaitingYouSection: View {
    let backlog: AtlasAutonomosBacklogResponse?
    let onOpenDetail: (AutonomosDetailSheet) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var inboxDecisions: [AtlasAutonomosInboxItem] {
        backlog?.inboxItems.filter(\.decisionRequired) ?? []
    }

    var workOrderDecisions: [AtlasAutonomosWorkOrder] {
        backlog?.workOrders.filter(\.operatorDecisionRequired) ?? []
    }

    var decisionCount: Int {
        inboxDecisions.count + workOrderDecisions.count
    }

    var body: some View {
        if decisionCount > 0 {
            VStack(alignment: .leading, spacing: 10) {
                awaitingHeader
                Text("Há decisão pública pendente; nada aqui afirma execução antes do recibo do owner.")
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .accessibilityHidden(true)
                awaitingChips
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.domOperacional.opacity(0.08)))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.domOperacional.opacity(0.38), lineWidth: 1))
            .accessibilityElement(children: .contain)
            .accessibilityLabel(sectionSpokenLabel)
            .accessibilityHint("abre inbox ou ordens com decisão pública pendente")
            .accessibilityIdentifier(A11yID.autonomosAwaitingYou)
            .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: decisionCount)
        }
    }
}
