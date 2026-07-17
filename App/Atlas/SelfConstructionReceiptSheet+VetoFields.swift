import SwiftUI
import AtlasCore

// Veto fields — peel de SelfConstructionReceiptSheet+Veto.
// Text → SelfConstructionReceiptSheet+VetoTextFields.swift

extension SelfConstructionReceiptSheet {
    var vetoFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("veto retroativo · com recibo")
                .font(AtlasFont.mono(10))
                .tracking(0.9)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            vetoTextFields
            vetoSubmitButton
        }
    }
}
