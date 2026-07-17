import WidgetKit
import SwiftUI
import AtlasCore

// Title row — peel de AtlasWidgetAccessories+CodeWeek+Header.

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekHeaderTitleRow(week: AtlasNativeSnapshot.Week) -> some View {
        HStack {
            Text("✦ Semana")
                .font(.system(size: 14, weight: .semibold, design: .serif))
            Spacer()
            Text(week.window)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.ink2)
        }
    }
}
