import WidgetKit
import SwiftUI
import AtlasCore

// Lock rect incident/paused — peel de LockRect Branches.

extension LockAccessorySnapshotView {
    @ViewBuilder
    func rectangularAlertBody(
        _ snapshot: AtlasNativeSnapshot,
        incidentLine: String?
    ) -> some View {
        if let incidentLine {
            rectangularIncidentBody(incidentLine)
        } else if let paused = snapshot.liveSessions?.first(where: { $0.timing == .paused }) {
            rectangularPausedBody(paused, snapshot: snapshot)
        }
    }
}
