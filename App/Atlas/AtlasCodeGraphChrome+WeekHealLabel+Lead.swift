import SwiftUI
import AtlasCore

// Week heal lead — peel de AtlasCodeGraphChrome+WeekHealLabel.

extension AtlasCodeView {
    @ViewBuilder
    var weekHealReceiptLabelLead: some View {
        Image(systemName: "checkmark.seal")
            .atlasSans(12)
            .foregroundStyle(AtlasCodePalette.healed)
            .accessibilityHidden(true)
        Text("curado sozinho · ver recibo")
            .font(AtlasFont.serifItalic(13))
            .foregroundStyle(AtlasTheme.textSecondary)
            .accessibilityHidden(true)
    }
}
