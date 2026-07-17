import SwiftUI
import AtlasCore

// Veto section — peel de SelfConstructionReceiptSheet.
// Fields → SelfConstructionReceiptSheet+VetoFields.swift

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var vetoSection: some View {
        if canRevert {
            vetoFields
                .accessibilityElement(children: .contain)
                .accessibilityLabel("veto retroativo com recibo")
        }
    }
}
