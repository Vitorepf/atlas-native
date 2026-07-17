import WidgetKit
import SwiftUI
import AtlasCore

// Lock inline family branch — peel de AtlasWidgetAccessories+LockLive+Content.

extension LockAccessorySnapshotView {
    @ViewBuilder
    func lockAccessoryInlineContent(_ snapshot: AtlasNativeSnapshot) -> some View {
        Text(LockAccessoryA11y.inlineText(snapshot))
            .foregroundStyle(emphasisColor(snapshot))
    }
}
