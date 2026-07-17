import WidgetKit
import SwiftUI
import AtlasCore

// Active live body branch — peel de AtlasWidgetAccessories+LiveSession+Content.

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionActiveBranch(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        liveSessionActiveBody(live)
    }
}
