import SwiftUI
import AtlasCore

// Live Activity note — peel de ArenaNowSection+Body.

extension ArenaNowSection {
    var nowLiveActivityNote: some View {
        Text("Seguir medição na Live Activity: pendente de ActivityKit dedicado para Arena.")
            .font(.system(.caption))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
            .accessibilityIdentifier(A11yID.arenaNowLiveActivityNote)
    }
}
