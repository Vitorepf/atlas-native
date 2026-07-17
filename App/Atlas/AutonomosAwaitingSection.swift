import SwiftUI
import AtlasCore

/// M139 — decisões públicas pendentes; silêncio total quando count = 0.
/// Chips/nightly/rhythm: AutonomosAwaitingSection+Blocks.swift
struct AutonomosAwaitingYouSection: View {
    let backlog: AtlasAutonomosBacklogResponse?
    let onOpenDetail: (AutonomosDetailSheet) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var inboxDecisions: [AtlasAutonomosInboxItem] {
        backlog?.inboxItems.filter(\.decisionRequired) ?? []
    }

    private var workOrderDecisions: [AtlasAutonomosWorkOrder] {
        backlog?.workOrders.filter(\.operatorDecisionRequired) ?? []
    }

    private var decisionCount: Int {
        inboxDecisions.count + workOrderDecisions.count
    }

    var body: some View {
        if decisionCount > 0 {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    AutonomosChrome.sectionCaption("AGUARDANDO VOCÊ")
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    Text("\(decisionCount)")
                        .font(AtlasFont.mono(13))
                        .foregroundStyle(AtlasTheme.domOperacional)
                        .modifier(NumericTextTransition(enabled: !reduceMotion))
                }
                Text("Há decisão pública pendente; nada aqui afirma execução antes do recibo do owner.")
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textSecondary)
                HStack(spacing: 8) {
                    if !inboxDecisions.isEmpty {
                        AutonomosDetailChipButton(
                            label: "inbox \(inboxDecisions.count)",
                            kind: .inbox,
                            spokenLabel: inboxSpokenLabel(count: inboxDecisions.count),
                            action: { onOpenDetail(.inbox) }
                        )
                    }
                    if !workOrderDecisions.isEmpty {
                        AutonomosDetailChipButton(
                            label: "ordens \(workOrderDecisions.count)",
                            kind: .workOrders,
                            spokenLabel: workOrdersSpokenLabel(count: workOrderDecisions.count),
                            action: { onOpenDetail(.workOrders) }
                        )
                    }
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.domOperacional.opacity(0.08)))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.domOperacional.opacity(0.38), lineWidth: 1))
            .accessibilityElement(children: .contain)
            .accessibilityLabel(sectionSpokenLabel)
            .accessibilityIdentifier(A11yID.autonomosAwaitingYou)
            .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: decisionCount)
        }
    }

    private var sectionSpokenLabel: String {
        if decisionCount == 1 {
            return "aguardando você, 1 decisão pendente"
        }
        return "aguardando você, \(decisionCount) decisões pendentes"
    }

    private func inboxSpokenLabel(count: Int) -> String {
        count == 1
            ? "abrir 1 decisão de inbox pendente"
            : "abrir \(count) decisões de inbox pendentes"
    }

    private func workOrdersSpokenLabel(count: Int) -> String {
        count == 1
            ? "abrir 1 ordem aguardando sua decisão"
            : "abrir \(count) ordens aguardando sua decisão"
    }
}

extension AutonomosAwaitingYouSection {
    static func decisionCount(in backlog: AtlasAutonomosBacklogResponse?) -> Int {
        guard let backlog else { return 0 }
        return backlog.inboxItems.filter(\.decisionRequired).count
            + backlog.workOrders.filter(\.operatorDecisionRequired).count
    }
}
