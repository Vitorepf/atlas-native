import WidgetKit
import SwiftUI
import AtlasCore

// Week header — peel de AtlasWidgetAccessories+CodeWeek+Body.

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekHeader(week: AtlasNativeSnapshot.Week, stale: Bool, age: String) -> some View {
        HStack {
            Text("✦ Semana")
                .font(.system(size: 14, weight: .semibold, design: .serif))
            Spacer()
            Text(week.window)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.ink2)
        }
        if stale {
            Text("visto \(age)")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.alert)
        }
    }
}
