import SwiftUI
import AtlasCore

// Card chrome — peel de AutonomosChrome+Metrics.
// ValueStack → AutonomosChrome+Metrics+ValueStack.swift

extension FleetMetric {
    var metricCardChrome: some View {
        metricValueStack
            .frame(maxWidth: .infinity, alignment: .leading).padding(11)
            .atlasCard(cornerRadius: AtlasTheme.Radius.control)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(label), \(value)")
    }
}
