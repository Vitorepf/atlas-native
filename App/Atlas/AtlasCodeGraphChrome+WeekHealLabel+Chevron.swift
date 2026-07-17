import SwiftUI
import AtlasCore

// Week heal chevron — peel de AtlasCodeGraphChrome+WeekHealLabel.

extension AtlasCodeView {
    @ViewBuilder
    var weekHealReceiptLabelChevron: some View {
        Spacer()
        Image(systemName: "chevron.right")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}
