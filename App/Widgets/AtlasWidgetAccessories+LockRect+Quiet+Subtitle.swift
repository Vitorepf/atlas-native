import WidgetKit
import SwiftUI
import AtlasCore

// Quiet subtitle — peel de LockRect+Quiet.
// Stale → AtlasWidgetAccessories+LockRect+Quiet+Subtitle+Stale.swift

extension LockAccessorySnapshotView {
    @ViewBuilder
    func rectangularQuietSubtitle(_ snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        if stale {
            rectangularQuietStaleSubtitle(snapshot)
        } else if let sub = LockAccessoryA11y.rectangularSubtitle(snapshot) {
            Text(sub)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Ink.ink2)
        }
    }
}
