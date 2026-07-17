import SwiftUI
import AtlasCore

// Now section chrome — peel de ArenaNowSection.

extension ArenaNowSection {
    var nowSectionBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AGORA")
                .font(.system(.caption, weight: .semibold))
                .tracking(1.4)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityAddTraits(.isHeader)
            nowRunRows
            Text("Seguir medição na Live Activity: pendente de ActivityKit dedicado para Arena.")
                .font(.system(.caption))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
                .accessibilityIdentifier(A11yID.arenaNowLiveActivityNote)
        }
        .padding(16)
        .atlasCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ArenaNowSectionA11y.spokenSection(runCount: runs.count))
        .accessibilityIdentifier(A11yID.arenaNowSection)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: runs.map(\.id))
    }
}
