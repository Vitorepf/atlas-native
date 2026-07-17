import WidgetKit
import SwiftUI
import AtlasCore

// Week body a11y — peel de AtlasWidgetAccessories+CodeWeek+Body.

extension CodeWeekWidgetView {
    func weekBodyA11y<V: View>(
        _ content: V,
        week: AtlasNativeSnapshot.Week,
        stale: Bool,
        age: String
    ) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(CodeWeekWidgetA11y.spokenLabel(week: week, stale: stale, age: age))
    }
}
