import SwiftUI
import AtlasCore

// Row header — peel de ArenaCapabilitiesSection+Rows.

extension ArenaCapabilityRow {
    var capabilityHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(capability.labelPt)
                .font(.system(.callout, weight: .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
                .accessibilityHidden(true)
            if capability.isContinuous {
                // Distingue média de score (rougeL) de taxa de acerto (pass@1) —
                // 0.14-rougeL não é 0.14-pass@1. Sem isso o número lê fora de escala.
                Text("média")
                    .font(AtlasFont.mono(8))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Capsule().fill(AtlasTheme.surfaceHi))
                    .accessibilityHidden(true)
            }
            Spacer()
            Text("\(ArenaFormat.score(capability.score)) · Atlas \(ArenaFormat.score(capability.withAtlas))")
                .font(AtlasFont.mono(11))
                .foregroundStyle(capability.score == nil ? AtlasTheme.textTertiary : AtlasTheme.textSecondary)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }
}
