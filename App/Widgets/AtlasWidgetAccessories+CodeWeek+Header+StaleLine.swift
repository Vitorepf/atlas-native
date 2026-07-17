import WidgetKit
import SwiftUI
import AtlasCore

// Stale age — peel de AtlasWidgetAccessories+CodeWeek+Header.

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekHeaderStaleLine(stale: Bool, age: String) -> some View {
        if stale {
            Text("visto \(age)")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.alert)
        }
    }
}
