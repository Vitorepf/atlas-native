import WidgetKit
import SwiftUI
import AtlasCore

// Branches do retângulo lock — peel de LockRect.
// Quiet → AtlasWidgetAccessories+LockRect+Quiet.swift
// Paused → AtlasWidgetAccessories+LockRect+Paused.swift
// Incident → AtlasWidgetAccessories+LockRect+Branches+Incident.swift
// Alert → AtlasWidgetAccessories+LockRect+Branches+Alert.swift

extension LockAccessorySnapshotView {
    @ViewBuilder
    func rectangularBody(_ snapshot: AtlasNativeSnapshot, stale: Bool, incidentLine: String?) -> some View {
        if incidentLine != nil || snapshot.liveSessions?.contains(where: { $0.timing == .paused }) == true {
            rectangularAlertBody(snapshot, incidentLine: incidentLine)
        } else {
            rectangularQuietBody(snapshot, stale: stale)
        }
    }
}
