import WidgetKit
import SwiftUI
import AtlasCore

// Live titles — peel de LiveSessionWidgetView+Bodies.
// Title → AtlasWidgetAccessories+LiveSession+Titles+Title.swift

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionTitles(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        liveSessionTitleLine(live)
        Text(live.phaseTitle)
            .font(.system(size: 14, design: .serif))
            .italic()
            .foregroundStyle(live.timing == .paused ? Ink.gold : Ink.ink2)
            .lineLimit(1)
            .accessibilityHidden(true)
    }
}
