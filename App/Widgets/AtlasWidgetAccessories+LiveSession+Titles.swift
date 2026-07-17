import WidgetKit
import SwiftUI
import AtlasCore

// Live titles — peel de LiveSessionWidgetView+Bodies.

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionTitles(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        Text(live.title)
            .font(.system(size: 17, weight: .semibold, design: .serif))
            .foregroundStyle(Ink.ink)
            .lineLimit(1)
            .accessibilityHidden(true)
        Text(live.phaseTitle)
            .font(.system(size: 14, design: .serif))
            .italic()
            .foregroundStyle(live.timing == .paused ? Ink.gold : Ink.ink2)
            .lineLimit(1)
            .accessibilityHidden(true)
    }
}
