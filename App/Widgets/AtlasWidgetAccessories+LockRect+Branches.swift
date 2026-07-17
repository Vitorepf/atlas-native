import WidgetKit
import SwiftUI
import AtlasCore

// Branches do retângulo lock — peel de LockRect.
// Quiet → AtlasWidgetAccessories+LockRect+Quiet.swift
// Paused → AtlasWidgetAccessories+LockRect+Paused.swift

extension LockAccessorySnapshotView {
    @ViewBuilder
    func rectangularBody(_ snapshot: AtlasNativeSnapshot, stale: Bool, incidentLine: String?) -> some View {
        if let incidentLine {
            Text(incidentLine)
                .font(.system(size: 13, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.alert)
                .lineLimit(2)
        } else if let paused = snapshot.liveSessions?.first(where: { $0.timing == .paused }) {
            rectangularPausedBody(paused, snapshot: snapshot)
        } else {
            rectangularQuietBody(snapshot, stale: stale)
        }
    }
}
