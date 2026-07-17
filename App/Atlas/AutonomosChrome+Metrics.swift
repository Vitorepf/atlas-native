import SwiftUI
import AtlasCore

// Métricas — peel de AutonomosChrome.
// Empty states → AutonomosChrome+Empty.swift
// DetailMetric → AutonomosChrome+DetailMetric.swift

struct FleetMetric: View {
    let value: String; let label: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value).font(AtlasFont.mono(18)).foregroundStyle(AtlasTheme.textPrimary)
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
            Text(label).font(.caption2).foregroundStyle(AtlasTheme.textTertiary).lineLimit(2)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(11)
        .atlasCard(cornerRadius: 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(value)")
    }
}
