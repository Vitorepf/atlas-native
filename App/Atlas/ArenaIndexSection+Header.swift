import SwiftUI
import AtlasCore

// Header + captions — peel de ArenaIndexSection.

extension ArenaIndexSection {
    var chartEngine: AtlasArenaCompositeEngine? {
        composite.engines.first { engine in
            engine.history.contains { point in
                point.composite != nil || point.withAtlas != nil || point.withoutAtlas != nil
            }
        }
    }

    var coverageCaption: String {
        let base = "cobertura \(composite.suitesMeasured)/\(composite.suitesTotal)"
        guard composite.suitesMeasured < composite.suitesTotal else { return base }
        return "\(base) · parcial"
    }

    var sectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                Text("O ÍNDICE")
                    .font(.system(.caption, weight: .semibold))
                    .tracking(1.4)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                Text(coverageCaption)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            Spacer()
            if !composite.weightsPublic.isEmpty {
                Text("\(composite.weightsPublic.count) pesos")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(sectionSpokenLabel)
    }
}
