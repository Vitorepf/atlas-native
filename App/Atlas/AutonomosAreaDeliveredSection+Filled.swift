import SwiftUI
import AtlasCore

// Delivered filled stack — peel de AutonomosAreaDeliveredSection.

extension AutonomosAreaDeliveredSection {
    @ViewBuilder
    func deliveredFilled(delivered: AtlasAutonomosDeliveredResponse, isSelf: Bool, deliveredTotal: Int) -> some View {
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
    }
}
