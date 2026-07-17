import SwiftUI
import AtlasCore

// Veto text fields — peel de SelfConstructionReceiptSheet+VetoFields.

extension SelfConstructionReceiptSheet {
    var vetoTextFields: some View {
        Group {
            TextField("Quem autoriza", text: $actor)
                .font(.system(.callout))
                .textInputAutocapitalization(.never)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(AtlasTheme.surface.opacity(0.55)))
                .accessibilityLabel("quem autoriza o veto")
                .accessibilityHint(spokenActorHint())
            TextField("Motivo auditável", text: $reason, axis: .vertical)
                .font(.system(.callout))
                .lineLimit(2...4)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(AtlasTheme.surface.opacity(0.55)))
                .accessibilityLabel("motivo auditável do veto")
                .accessibilityHint(spokenReasonHint())
        }
    }
}
