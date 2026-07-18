import SwiftUI
import AtlasCore

// Snapshot age line — peel de AtlasArenaView+Header.

extension AtlasArenaView {
    @ViewBuilder
    var headerAge: some View {
        if let age = model.snapshotAgeText, model.composite != nil {
            Text("medido \(age)")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
