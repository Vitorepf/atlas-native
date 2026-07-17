import SwiftUI
import AtlasCore

// Week title row — peel de AtlasCodeGraphChrome+WeekBody.

extension AtlasCodeView {
    func weekTitleRow(_ week: AtlasCodeWeek) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text("A semana")
                .font(AtlasFont.serif(18, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Spacer()
            Text(week.window)
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
