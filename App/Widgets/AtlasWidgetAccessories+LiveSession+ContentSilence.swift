import WidgetKit
import SwiftUI
import AtlasCore

// Silence body branch — peel de AtlasWidgetAccessories+LiveSession+Content.

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionSilenceBranch(_ snapshot: AtlasNativeSnapshot) -> some View {
        liveSessionSilenceBody(snapshot)
    }
}
