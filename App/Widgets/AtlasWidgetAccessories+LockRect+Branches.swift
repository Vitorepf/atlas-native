import WidgetKit
import SwiftUI
import AtlasCore

// Branches do retângulo lock — peel de LockRect.
// Quiet → AtlasWidgetAccessories+LockRect+Quiet.swift

extension LockAccessorySnapshotView {
    @ViewBuilder
    func rectangularBody(_ snapshot: AtlasNativeSnapshot, stale: Bool, incidentLine: String?) -> some View {
        if let incidentLine {
            Text(incidentLine)
                .font(.system(size: 13, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.alert)
                .lineLimit(2)
        } else if let paused = snapshot.liveSessions?.first(where: { $0.timing == .paused }) {
            Text(paused.phaseTitle)
                .font(.system(size: 13, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.alert)
                .lineLimit(1)
            if let sub = LockAccessoryA11y.rectangularSubtitle(snapshot) {
                Text(sub)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Ink.alert)
            }
        } else {
            rectangularQuietBody(snapshot, stale: stale)
        }
    }
}
