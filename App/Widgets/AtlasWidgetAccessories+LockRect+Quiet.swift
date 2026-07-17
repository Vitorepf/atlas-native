import WidgetKit
import SwiftUI
import AtlasCore

// Quiet / stale branch — peel de LockRect+Branches.
// Title → AtlasWidgetAccessories+LockRect+Quiet+Title.swift
// Subtitle → AtlasWidgetAccessories+LockRect+Quiet+Subtitle.swift

extension LockAccessorySnapshotView {
    @ViewBuilder
    func rectangularQuietBody(_ snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        rectangularQuietTitle(snapshot)
        rectangularQuietSubtitle(snapshot, stale: stale)
    }
}
