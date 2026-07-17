import SwiftUI
import AtlasCore

// Corpo regra/prova — peel de SelfConstructionReceiptSheet (régua ≤100).
// Revert → SelfConstructionReceiptSheet+RevertBanner.swift

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

    @ViewBuilder
    var proofBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prova")
                .font(AtlasFont.mono(10))
                .tracking(0.9)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(receipt.proofLine)
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textPrimary)
                .textSelection(.enabled)
                .accessibilityHidden(true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenProofLabel())
    }
}
