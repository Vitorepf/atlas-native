import WidgetKit
import SwiftUI
import AtlasCore

// Branches do retângulo lock — peel de LockRect.
// Quiet → AtlasWidgetAccessories+LockRect+Quiet.swift
// Paused → AtlasWidgetAccessories+LockRect+Paused.swift
// Incident → AtlasWidgetAccessories+LockRect+Branches+Incident.swift

extension LockAccessorySnapshotView {
    @ViewBuilder
    func rectangularBody(_ snapshot: AtlasNativeSnapshot, stale: Bool, incidentLine: String?) -> some View {
        if let incidentLine {
            rectangularIncidentBody(incidentLine)
        } else if let paused = snapshot.liveSessions?.first(where: { $0.timing == .paused }) {
            rectangularPausedBody(paused, snapshot: snapshot)
        } else {
            rectangularQuietBody(snapshot, stale: stale)
        }
    }
}
