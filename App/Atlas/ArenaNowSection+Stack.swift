import SwiftUI
import AtlasCore

// Stack AGORA — peel de ArenaNowSection+Body.

extension ArenaNowSection {
    var nowSectionStack: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AGORA")
                .font(.system(.caption, weight: .semibold))
                .tracking(1.4)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityAddTraits(.isHeader)
            nowRunRows
            nowLiveActivityNote
        }
        .padding(16)
        .atlasCard()
    }
}
