import SwiftUI
import AtlasCore

// Botão recibo de cura — peel de AtlasCodeGraphChrome+Week.

extension AtlasCodeView {
    @ViewBuilder
    var weekHealReceiptButton: some View {
        if model.hasHealReceipt {
            Button { showsHealReceipt = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: 12))
                        .foregroundStyle(AtlasCodePalette.healed)
                        .accessibilityHidden(true)
                    Text("curado sozinho · ver recibo")
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .accessibilityHidden(true)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
                .padding(.vertical, 11)
                .padding(.horizontal, 13)
                .background(AtlasCodePalette.healed.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(AtlasCodePalette.healed.opacity(0.3), lineWidth: 1)
                )
            }
            .accessibilityIdentifier(A11yID.codeHealReceipt)
            .accessibilityLabel("curado sozinho, ver recibo de cura")
            .accessibilityHint("abre os passos registrados pelo servidor")
        }
    }
}
