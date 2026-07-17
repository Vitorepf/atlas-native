import WidgetKit
import SwiftUI
import AtlasCore

// Live title line — peel de LiveSession Titles.

extension LiveSessionWidgetView {
    func liveSessionTitleLine(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        Text(live.title)
            .font(.system(size: 17, weight: .semibold, design: .serif))
            .foregroundStyle(Ink.ink)
            .lineLimit(1)
            .accessibilityHidden(true)
    }
}
