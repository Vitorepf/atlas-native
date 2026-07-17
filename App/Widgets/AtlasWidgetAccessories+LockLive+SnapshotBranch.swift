import WidgetKit
import SwiftUI
import AtlasCore

// Snapshot branch — peel de LockAccessorySnapshotView.

extension LockAccessorySnapshotView {
    @ViewBuilder
    var snapshotBranch: some View {
        if let snapshot = entry.snapshot {
            lockAccessoryContent(snapshot)
        } else {
            lockAccessoryEmpty
        }
    }
}
