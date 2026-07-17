import WidgetKit
import SwiftUI
import AtlasCore

// Stale quiet subtitle — peel de LockRect Quiet Subtitle.

extension LockAccessorySnapshotView {
    @ViewBuilder
    func rectangularQuietStaleSubtitle(_ snapshot: AtlasNativeSnapshot) -> some View {
        Text("visto \(snapshot.ageText(at: entry.date))")
            .font(.system(size: 11, design: .monospaced))
            .foregroundStyle(Ink.alert)
    }
}
