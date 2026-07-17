import WidgetKit
import SwiftUI
import AtlasCore

// Incident branch — peel de AtlasWidgetAccessories+LockRect+Branches.

extension LockAccessorySnapshotView {
    @ViewBuilder
    func rectangularIncidentBody(_ incidentLine: String) -> some View {
        Text(incidentLine)
            .font(.system(size: 13, weight: .semibold, design: .serif))
            .foregroundStyle(Ink.alert)
            .lineLimit(2)
    }
}
