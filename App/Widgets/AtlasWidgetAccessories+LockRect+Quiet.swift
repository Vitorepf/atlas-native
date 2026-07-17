import WidgetKit
import SwiftUI
import AtlasCore

// Quiet / stale branch — peel de LockRect+Branches.

extension LockAccessorySnapshotView {
    @ViewBuilder
    func rectangularQuietBody(_ snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        Text(snapshot.liveSessions?.first?.phaseTitle ?? "silêncio na obra")
            .font(.system(size: 13, weight: .semibold, design: .serif))
            .lineLimit(1)
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
