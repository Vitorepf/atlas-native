import SwiftUI
import AtlasCore

// Regra — peel de SelfConstructionReceiptSheet+Body.

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var ruleBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Regra citada")
                .font(AtlasFont.mono(10))
                .tracking(0.9)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text("“\(receipt.ruleLabel)”")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenRuleLabel())
    }
}
