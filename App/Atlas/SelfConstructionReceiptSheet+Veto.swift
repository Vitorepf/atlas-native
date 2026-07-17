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
                TextField("Quem autoriza", text: $actor)
                    .font(.system(.callout))
                    .textInputAutocapitalization(.never)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(AtlasTheme.surface.opacity(0.55)))
                TextField("Motivo auditável", text: $reason, axis: .vertical)
                    .font(.system(.callout))
                    .lineLimit(2...4)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(AtlasTheme.surface.opacity(0.55)))
                Button {
                    onRevert(actor, reason)
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "arrow.uturn.backward")
                        Text("Desfazer — com recibo")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(AtlasTheme.domOperacional)
                    .atlasCard(cornerRadius: 13)
                }
                .disabled(!canSubmitRevert)
                .accessibilityIdentifier(A11yID.selfReceiptVeto)
            }
        } else {
            Text("silêncio · desfazer indisponível neste recorte")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }
}
