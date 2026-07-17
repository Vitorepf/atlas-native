import WidgetKit
import SwiftUI
import AtlasCore

// Silence body — peel de LiveSessionWidgetView bodies.

extension LiveSessionWidgetView {
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
