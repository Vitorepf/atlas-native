import SwiftUI
import AtlasCore

// Quiet / metrics — peel de AtlasCodeGraphChrome+WeekBody.

extension AtlasCodeView {
    @ViewBuilder
    func weekMetricsOrQuiet(_ week: AtlasCodeWeek) -> some View {
        if AtlasCodeWeekUI.isQuiet(week) {
            Text("semana quieta · sem commits nem curas")
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        } else {
            HStack(spacing: 18) {
                if week.commits > 0 { weekMetric("commits", value: week.commits) }
                if week.heals > 0 { weekMetric("curas", value: week.heals) }
                if week.prevented > 0 { weekMetric("prevenidas", value: week.prevented) }
            }
            .accessibilityHidden(true)
        }
    }
}
