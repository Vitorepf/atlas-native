import WidgetKit
import SwiftUI
import AtlasCore

// Lock circular branch — peel de AtlasWidgetAccessories+LockLive+Content.

extension LockAccessorySnapshotView {
    @ViewBuilder
    func lockAccessoryCircularContent(_ snapshot: AtlasNativeSnapshot) -> some View {
        circular(snapshot)
    }
}
