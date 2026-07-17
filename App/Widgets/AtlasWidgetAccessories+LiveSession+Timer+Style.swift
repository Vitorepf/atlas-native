import SwiftUI
import AtlasCore

// Timer typography — peel de AtlasWidgetAccessories+LiveSession+Timer.

extension LiveSessionWidgetTimer {
    @ViewBuilder
    func timerStyle<Content: View>(_ content: Content) -> some View {
        content
            .font(.system(size: 13, design: .monospaced))
            .foregroundStyle(live.timing == .paused ? Ink.gold : Ink.ink2)
            .accessibilityHidden(true)
    }
}
