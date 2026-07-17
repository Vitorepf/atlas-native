import WidgetKit
import SwiftUI
import AtlasCore

// Lock accessory family switch — peel de AtlasWidgetAccessories+LockLive.
// Inline → AtlasWidgetAccessories+LockLive+ContentInline.swift
// Circular → AtlasWidgetAccessories+LockLive+ContentCircular.swift
// Family → AtlasWidgetAccessories+LockLive+Content+Family.swift

extension LockAccessorySnapshotView {
    @ViewBuilder
    func lockAccessoryContent(_ snapshot: AtlasNativeSnapshot) -> some View {
        lockAccessoryFamilyBranch(snapshot)
    }
}
