import SwiftUI
import AtlasCore

// DetailMetric — peel de AutonomosChrome+Metrics.

struct DetailMetric: View {
    let label: String; let value: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(AtlasFont.mono(15)).foregroundStyle(AtlasTheme.textPrimary)
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
            Text(label).font(.caption2).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(value)")
    }
}
