import SwiftUI
import AtlasCore

// Week heal button label — peel de AtlasCodeGraphChrome+WeekHeal.
// Chrome → AtlasCodeGraphChrome+WeekHealChrome.swift

extension AtlasCodeView {
    var weekHealReceiptLabel: some View {
        weekHealChrome(
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
        )
    }
}
