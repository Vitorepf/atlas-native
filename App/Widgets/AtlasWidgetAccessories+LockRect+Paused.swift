import WidgetKit
import SwiftUI
import AtlasCore

// Lock rect paused — peel de LockRect+Branches.

extension LockAccessorySnapshotView {
    @ViewBuilder
    func rectangularPausedBody(_ paused: AtlasNativeSnapshot.LiveSession, snapshot: AtlasNativeSnapshot) -> some View {
        Text(paused.phaseTitle)
            .font(.system(size: 13, weight: .semibold, design: .serif))
            .foregroundStyle(Ink.alert)
            .lineLimit(1)
        if let sub = LockAccessoryA11y.rectangularSubtitle(snapshot) {
            Text(sub)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Ink.alert)
        }
    }
}
