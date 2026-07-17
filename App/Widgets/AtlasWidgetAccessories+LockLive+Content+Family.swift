import WidgetKit
import SwiftUI
import AtlasCore

// Lock circular branch — peel de AtlasWidgetAccessories+LockLive+Content.

extension LockAccessorySnapshotView {
    @ViewBuilder
    func lockAccessoryFamilyBranch(_ snapshot: AtlasNativeSnapshot) -> some View {
        if family == .accessoryCircular {
            lockAccessoryCircularContent(snapshot)
        } else if family == .accessoryInline {
            lockAccessoryInlineContent(snapshot)
        } else {
            lockAccessoryRectangularContent(snapshot)
        }
    }
}
