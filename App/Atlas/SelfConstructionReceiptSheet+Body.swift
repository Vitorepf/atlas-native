import SwiftUI
import AtlasCore

// Prova — peel de SelfConstructionReceiptSheet (régua ≤100).
// Revert → SelfConstructionReceiptSheet+RevertBanner.swift
// Rule → SelfConstructionReceiptSheet+Rule.swift
// Chrome → SelfConstructionReceiptSheet+ProofChrome.swift

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var proofBlock: some View {
        proofChrome(
            VStack(alignment: .leading, spacing: 8) {
                Text("Prova")
                    .font(AtlasFont.mono(10))
                    .tracking(0.9)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                proofCopyBlock
            }
        )
    }
}
