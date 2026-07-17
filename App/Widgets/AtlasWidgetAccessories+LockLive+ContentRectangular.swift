import WidgetKit
import SwiftUI
import AtlasCore

// Lock rectangular branch — peel de AtlasWidgetAccessories+LockLive+Content.

extension LockAccessorySnapshotView {
    @ViewBuilder
    func lockAccessoryRectangularContent(_ snapshot: AtlasNativeSnapshot) -> some View {
        rectangular(snapshot)
    }
}
