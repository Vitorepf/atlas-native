import WidgetKit
import SwiftUI
import AtlasCore

// Spoken combine — peel de AtlasWidgetAccessories+LiveSession+A11ySpokenBind.

extension LiveSessionWidgetView {
    func liveSessionSpokenCombine<Content: View>(_ content: Content) -> some View {
        content.accessibilityElement(children: .combine)
    }
}
