import WidgetKit
import SwiftUI
import AtlasCore

// Quiet branch — peel de CodeWeek+Quiet.

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekQuietBranch() -> some View {
        Text("semana quieta · sem commits nem curas")
            .font(.system(size: 16, weight: .semibold, design: .serif))
            .foregroundStyle(Ink.ink2)
            .lineLimit(2)
    }
}
