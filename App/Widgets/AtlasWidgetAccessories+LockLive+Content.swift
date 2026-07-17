import WidgetKit
import SwiftUI
import AtlasCore

// Lock accessory family switch — peel de AtlasWidgetAccessories+LockLive.
// Inline → AtlasWidgetAccessories+LockLive+ContentInline.swift
// Circular → AtlasWidgetAccessories+LockLive+ContentCircular.swift

extension LockAccessorySnapshotView {
    @ViewBuilder
    func lockAccessoryContent(_ snapshot: AtlasNativeSnapshot) -> some View {
        switch family {
        case .accessoryCircular:
            lockAccessoryCircularContent(snapshot)
        case .accessoryInline:
            lockAccessoryInlineContent(snapshot)
        default:
            lockAccessoryRectangularContent(snapshot)
        }
    }
}
