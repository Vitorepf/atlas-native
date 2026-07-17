import WidgetKit
import SwiftUI
import AtlasCore

// Lock accessory family switch — peel de AtlasWidgetAccessories+LockLive.

extension LockAccessorySnapshotView {
    @ViewBuilder
    func lockAccessoryContent(_ snapshot: AtlasNativeSnapshot) -> some View {
        switch family {
        case .accessoryCircular:
            circular(snapshot)
        case .accessoryInline:
            Text(LockAccessoryA11y.inlineText(snapshot))
                .foregroundStyle(emphasisColor(snapshot))
        default:
            rectangular(snapshot)
        }
    }
}
