import WidgetKit
import SwiftUI
import AtlasCore

// Quiet subtitle — peel de LockRect+Quiet.

extension LockAccessorySnapshotView {
    @ViewBuilder
    func rectangularQuietSubtitle(_ snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        if stale {
            Text("visto \(snapshot.ageText(at: entry.date))")
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Ink.alert)
        } else if let sub = LockAccessoryA11y.rectangularSubtitle(snapshot) {
            Text(sub)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Ink.ink2)
        }
    }
}
