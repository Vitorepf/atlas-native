import SwiftUI
import AtlasCore

// Prova — peel de SelfConstructionReceiptSheet (régua ≤100).
// Revert → SelfConstructionReceiptSheet+RevertBanner.swift
// Rule → SelfConstructionReceiptSheet+Rule.swift
// Chrome → SelfConstructionReceiptSheet+ProofChrome.swift
// Title → SelfConstructionReceiptSheet+Body+Title.swift

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var proofBlock: some View {
        proofChrome(
            VStack(alignment: .leading, spacing: 8) {
                proofBlockTitle
                proofCopyBlock
            }
        )
    }
}
