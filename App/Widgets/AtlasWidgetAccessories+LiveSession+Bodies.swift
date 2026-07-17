import WidgetKit
import SwiftUI
import AtlasCore

// Live branch — peel de LiveSessionWidgetView+Content.

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionActiveBody(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
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
        HStack {
            LiveSessionWidgetTimer(live: live)
            Spacer()
            Text("Seguir")
                .font(.system(size: 12, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.bg)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Ink.gold))
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    func liveSessionSilenceBody(_ snapshot: AtlasNativeSnapshot) -> some View {
        Text("silêncio na obra")
            .font(.system(size: 17, weight: .semibold, design: .serif))
            .accessibilityHidden(true)
        Text(LiveSessionWidgetA11y.silenceDetail(snapshot))
            .font(.system(size: 12, design: .serif))
            .foregroundStyle(Ink.ink2)
            .accessibilityHidden(true)
    }
}
