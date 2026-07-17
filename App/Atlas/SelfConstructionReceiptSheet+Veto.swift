import SwiftUI
import AtlasCore

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var vetoSection: some View {
        if canRevert {
            VStack(alignment: .leading, spacing: 8) {
                Text("veto retroativo · com recibo")
                    .font(AtlasFont.mono(10))
                    .tracking(0.9)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
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
                Button {
                    if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
                    onRevert(actor, reason)
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "arrow.uturn.backward")
                            .accessibilityHidden(true)
                        Text("Desfazer — com recibo")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(AtlasTheme.domOperacional)
                    .atlasCard(cornerRadius: 13)
                }
                .buttonStyle(PressableScale())
                .disabled(!canSubmitRevert)
                .accessibilityIdentifier(A11yID.selfReceiptVeto)
                .accessibilityLabel(spokenVetoSubmitLabel(canSubmit: canSubmitRevert))
                .accessibilityHint(spokenVetoSubmitHint(canSubmit: canSubmitRevert))
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("veto retroativo com recibo")
        }
    }
}
