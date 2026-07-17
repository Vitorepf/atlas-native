import SwiftUI
import AtlasCore

/// M139 — decisões públicas pendentes; só aparece com count > 0.
struct AutonomosAwaitingYouSection: View {
    let backlog: AtlasAutonomosBacklogResponse?
    let onOpenDetail: (AutonomosDetailSheet) -> Void

    var body: some View {
        let inbox = backlog?.inboxItems.filter(\.decisionRequired) ?? []
        let workOrders = backlog?.workOrders.filter(\.operatorDecisionRequired) ?? []
        let count = inbox.count + workOrders.count
        if count > 0 {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    AutonomosChrome.sectionCaption("AGUARDANDO VOCÊ")
                    Spacer()
                    Text("\(count)")
                        .font(AtlasFont.mono(13))
                        .foregroundStyle(AtlasTheme.domOperacional)
                        .contentTransition(.numericText())
                }
                Text("Há decisão pública pendente; nada aqui afirma execução antes do recibo do owner.")
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textSecondary)
                HStack(spacing: 8) {
                    if !inbox.isEmpty {
                        AutonomosDetailChipButton(label: "inbox \(inbox.count)", kind: .inbox, action: { onOpenDetail(.inbox) })
                    }
                    if !workOrders.isEmpty {
                        AutonomosDetailChipButton(label: "ordens \(workOrders.count)", kind: .workOrders, action: { onOpenDetail(.workOrders) })
                    }
                    if backlog?.findings.returned ?? 0 > 0 {
                        AutonomosDetailChipButton(label: "findings", kind: .findings, action: { onOpenDetail(.findings) })
                    }
                    AutonomosDetailChipButton(label: "budgets", kind: .budgets, action: { onOpenDetail(.budgets) })
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.domOperacional.opacity(0.08)))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.domOperacional.opacity(0.38), lineWidth: 1))
            .accessibilityElement(children: .contain)
            .accessibilityLabel("aguardando você, \(count) decisões")
            .accessibilityIdentifier(A11yID.autonomosAwaitingYou)
        }
    }
}

struct AutonomosDetailChipButton: View {
    let label: String
    let kind: AutonomosDetailSheet
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textPrimary)
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background(Capsule().fill(AtlasTheme.surfaceHi))
                .overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("abrir detalhes de \(label)")
        .accessibilityIdentifier(A11yID.autonomosDetailButton(kind.id))
    }
}

/// Proposta das 21h — silêncio quando mute ativo ou sem proposta pendente.
struct AutonomosNightlyProposalBlock: View {
    let nightly: NightlyProposalController
    let onAccept: (NightlyProposalController.ProposalPayload) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if let proposal = nightly.pendingProposal, !nightly.isProposalMuted {
            NightlyProposalCard(
                proposal: proposal,
                onAccept: { onAccept(proposal) },
                onDismiss: { nightly.dismissProposal() },
                onMute: { nightly.muteProposal(days: $0) }
            )
            .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
        }
    }
}

/// M20 — ritmo aprendido; só com sampleDays < 4.
struct AutonomosRhythmLearningLine: View {
    let sampleDays: Int?

    var body: some View {
        if let sampleDays, sampleDays < 4 {
            Text("aprendendo seu ritmo · dia \(max(1, sampleDays)) de 4")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("aprendendo seu ritmo, dia \(max(1, sampleDays)) de 4")
        }
    }
}
