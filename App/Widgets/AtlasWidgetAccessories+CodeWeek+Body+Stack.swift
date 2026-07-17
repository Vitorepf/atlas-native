import WidgetKit
import SwiftUI
import AtlasCore

// Week body stack — peel de AtlasWidgetAccessories+CodeWeek+Body.

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekBodyStack(week: AtlasNativeSnapshot.Week, stale: Bool, age: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            weekHeader(week: week, stale: stale, age: age)
            weekMetricsOrQuiet(week)
            weekLargeHint(week)
            Spacer(minLength: 0)
        }
    }
}
