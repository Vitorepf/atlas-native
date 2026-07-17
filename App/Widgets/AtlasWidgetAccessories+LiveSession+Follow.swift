import WidgetKit
import SwiftUI
import AtlasCore

// Follow CTA — peel de AtlasWidgetAccessories+LiveSession+Bodies.

extension LiveSessionWidgetView {
    var liveSessionFollowChip: some View {
        Text("Seguir")
            .font(.system(size: 12, weight: .semibold, design: .serif))
            .foregroundStyle(Ink.bg)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(Ink.gold))
            .accessibilityHidden(true)
    }
}
