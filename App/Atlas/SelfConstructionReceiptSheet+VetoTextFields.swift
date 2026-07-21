import AtlasCore
import SwiftUI

// Cycle 041 fuse → SelfConstructionReceiptSheet+VetoTextFields.swift

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var proofBlockStack: some View {
        VStack(alignment: .leading, spacing: 8) {
            proofBlockTitle
            proofCopyBlock
        }
    }
}

extension SelfConstructionReceiptSheet {
    var proofBlockTitle: some View {
        Text("Prova")
            .font(AtlasFont.mono(10))
            .tracking(0.9)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var proofBlock: some View {
        proofChrome(proofBlockStack)
    }
}

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
