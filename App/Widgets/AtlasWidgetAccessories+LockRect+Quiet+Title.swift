import WidgetKit
import SwiftUI
import AtlasCore

// Quiet title — peel de LockRect+Quiet.

extension LockAccessorySnapshotView {
    func rectangularQuietTitle(_ snapshot: AtlasNativeSnapshot) -> some View {
        Text(snapshot.liveSessions?.first?.phaseTitle ?? "silêncio na obra")
            .font(.system(size: 13, weight: .semibold, design: .serif))
            .lineLimit(1)
    }
}
