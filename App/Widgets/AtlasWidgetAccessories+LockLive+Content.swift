import WidgetKit
import SwiftUI
import AtlasCore

// Lock accessory family switch — peel de AtlasWidgetAccessories+LockLive.
// Inline → AtlasWidgetAccessories+LockLive+ContentInline.swift

extension LockAccessorySnapshotView {
    @ViewBuilder
    func lockAccessoryContent(_ snapshot: AtlasNativeSnapshot) -> some View {
        switch family {
        case .accessoryCircular:
            circular(snapshot)
        case .accessoryInline:
            lockAccessoryInlineContent(snapshot)
        default:
            rectangular(snapshot)
        }
    }
}
