import WidgetKit
import SwiftUI
import AtlasCore

// Live branch — peel de LiveSessionWidgetView+Content.
// Silence → AtlasWidgetAccessories+LiveSession+Silence.swift
// Follow → AtlasWidgetAccessories+LiveSession+Follow.swift

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
            liveSessionFollowChip
        }
    }
}
