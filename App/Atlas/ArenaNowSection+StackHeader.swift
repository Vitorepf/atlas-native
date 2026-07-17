import SwiftUI
import AtlasCore

// AGORA header — peel de ArenaNowSection+Stack.

extension ArenaNowSection {
    var nowSectionHeader: some View {
        Text("AGORA")
            .font(.system(.caption, weight: .semibold))
            .tracking(1.4)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityAddTraits(.isHeader)
    }
}
