import AtlasCore
import SwiftUI

// Cycle 038 fuse → SelfConstructionReceiptSheet+VetoTextFields.swift

extension SelfConstructionReceiptSheet {
    var vetoActorField: some View {
        TextField("Quem autoriza", text: $actor)
            .font(.system(.callout))
            .textInputAutocapitalization(.never)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.surface.opacity(0.55)))
            .accessibilityLabel("quem autoriza o veto")
            .accessibilityHint(spokenActorHint())
    }
}

extension SelfConstructionReceiptSheet {
    var vetoReasonField: some View {
        TextField("Motivo auditável", text: $reason, axis: .vertical)
            .font(.system(.callout))
            .lineLimit(2...4)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.surface.opacity(0.55)))
            .accessibilityLabel("motivo auditável do veto")
            .accessibilityHint(spokenReasonHint())
    }
}

extension SelfConstructionReceiptSheet {
    var vetoTextFields: some View {
        Group {
            vetoActorField
            vetoReasonField
        }
    }
}
