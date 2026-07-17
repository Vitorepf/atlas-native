import SwiftUI
import AtlasCore

// Prova — peel de SelfConstructionReceiptSheet (régua ≤100).
// Revert → SelfConstructionReceiptSheet+RevertBanner.swift
// Rule → SelfConstructionReceiptSheet+Rule.swift

extension SelfConstructionReceiptSheet {
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
