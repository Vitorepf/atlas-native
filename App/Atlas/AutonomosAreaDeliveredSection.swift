import SwiftUI
import AtlasCore

// Entregas comprovadas — peel de AutonomosAreaDetailSection.

struct AutonomosAreaDeliveredSection: View {
    let area: AtlasAutonomosArea
    let model: AutonomosModel
    let onSelfConstructionReceipt: (SelfConstructionReceipt) -> Void

    @Environment(\.openURL) var openURL
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        deliveredSection
    }

    /// C13 + Elite C: merge comprovado = sucesso/silêncio; delivered_total=0
    /// em auto-construção = vazio honesto (nunca “melhorou” sem ledger).
    @ViewBuilder
    private var deliveredSection: some View {
        let isSelf = isSelfConstructionArea(area)
        let deliveredTotal = model.delivered?.deliveredTotal ?? 0
        if let delivered = model.delivered, deliveredTotal > 0 {
            let visible = min(delivered.delivered.count, AutonomosAreaDeliveredA11y.visibleCap)
            VStack(alignment: .leading, spacing: 6) {
                AutonomosChrome.sectionCaption(
                    AutonomosAreaDeliveredA11y.sectionCaption(isSelf: isSelf, total: deliveredTotal, visible: visible)
                )
                if isSelf {
                    Text("silêncio · você não foi necessário — só veto com recibo")
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityHidden(true)
                }
                ForEach(Array(delivered.delivered.prefix(AutonomosAreaDeliveredA11y.visibleCap).enumerated()), id: \.element.id) { index, cycle in
                    deliveredCycleRow(cycle: cycle, index: index, visible: visible, isSelf: isSelf)
                }
            }
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: deliveredTotal)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(AutonomosAreaDeliveredA11y.spokenSection(isSelf: isSelf, total: deliveredTotal, visible: visible))
            .accessibilityIdentifier(isSelf ? A11yID.autonomosAreaDeliveredSelf : A11yID.autonomosAreaDeliveredSection)
        } else if isSelf {
            VStack(alignment: .leading, spacing: 6) {
                AutonomosChrome.sectionCaption("AUTO-CONSTRUÇÃO", role: .header)
                Text("Trabalho ainda não mergeado — aguardando o ledger. Sem entrega comprovada neste recorte.")
                    .font(AtlasFont.serifItalic(13))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(AutonomosAreaDeliveredA11y.spokenEmptySelf())
            .accessibilityIdentifier(A11yID.autonomosAreaDeliveredEmpty)
        }
    }
}
