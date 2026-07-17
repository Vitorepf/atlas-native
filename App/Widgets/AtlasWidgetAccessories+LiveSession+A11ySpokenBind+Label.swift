import WidgetKit
import SwiftUI
import AtlasCore

// Spoken label — peel de AtlasWidgetAccessories+LiveSession+A11ySpokenBind.

extension LiveSessionWidgetView {
    func liveSessionSpokenLabelText(
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool
    ) -> String {
        LiveSessionWidgetA11y.spokenLabel(
            snapshot: snapshot,
            live: live,
            stale: stale,
            age: snapshot.ageText(at: entry.date)
        )
    }
}
