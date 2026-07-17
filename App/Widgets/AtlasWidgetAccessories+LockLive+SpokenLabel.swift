import WidgetKit
import SwiftUI
import AtlasCore

// Spoken label — peel de LockAccessorySnapshotView.

extension LockAccessorySnapshotView {
    var spokenLabel: String {
        guard let snapshot = entry.snapshot else { return "abra o Atlas para atualizar o snapshot" }
        return LockAccessoryA11y.spokenLabel(
            snapshot: snapshot,
            stale: snapshot.isStale(at: entry.date),
            age: snapshot.ageText(at: entry.date)
        )
    }
}
