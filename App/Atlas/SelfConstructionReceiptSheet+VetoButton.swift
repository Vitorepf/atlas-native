import SwiftUI
import AtlasCore

// Botão veto — peel de SelfConstructionReceiptSheet+Veto.
// Label → SelfConstructionReceiptSheet+VetoLabel.swift

extension SelfConstructionReceiptSheet {
    var vetoSubmitButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onRevert(actor, reason)
        } label: {
            vetoSubmitLabel
        }
        .buttonStyle(PressableScale())
        .disabled(!canSubmitRevert)
        .accessibilityIdentifier(A11yID.selfReceiptVeto)
        .accessibilityLabel(spokenVetoSubmitLabel(canSubmit: canSubmitRevert))
        .accessibilityHint(spokenVetoSubmitHint(canSubmit: canSubmitRevert))
    }
}
