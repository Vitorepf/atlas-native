import SwiftUI
import AtlasCore

// Proof stack — peel de SelfConstructionReceiptSheet+Body.

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var proofBlockStack: some View {
        VStack(alignment: .leading, spacing: 8) {
            proofBlockTitle
            proofCopyBlock
        }
    }
}
