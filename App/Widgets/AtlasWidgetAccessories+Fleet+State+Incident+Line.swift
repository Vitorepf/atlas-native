import WidgetKit
import SwiftUI
import AtlasCore

// Incident line text — peel de Fleet+State+Incident+Line.

extension FleetWidgetView {
    func fleetStateIncidentLineText(_ line: String) -> some View {
        Text(line)
            .font(.system(size: 16, weight: .semibold, design: .serif))
            .foregroundStyle(Ink.alert)
            .lineLimit(2)
    }
}
