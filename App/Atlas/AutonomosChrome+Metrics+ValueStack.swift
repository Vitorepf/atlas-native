import SwiftUI
import AtlasCore

// Value stack — peel de AutonomosChrome+Metrics.
// CardChrome → AutonomosChrome+Metrics+CardChrome.swift

extension FleetMetric {
    var metricValueStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value).font(AtlasFont.mono(18)).foregroundStyle(AtlasTheme.textPrimary)
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
            Text(label).font(.caption2).foregroundStyle(AtlasTheme.textTertiary).lineLimit(2)
                .accessibilityHidden(true)
        }
    }
}
