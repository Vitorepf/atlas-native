import SwiftUI
import AtlasCore

// Header ARENA — peel de AtlasArenaView.
// Age → AtlasArenaView+HeaderAge.swift

extension AtlasArenaView {
    var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("ARENA")
                .font(.system(.caption, weight: .semibold))
                .tracking(1.5)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text("Medição dos motores")
                .font(AtlasFont.serif(28, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            headerAge
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(headerSpokenLabel)
        .accessibilityAddTraits(.isHeader)
    }
}
