import SwiftUI
import AtlasCore

// Now section chrome — peel de ArenaNowSection.
// Live note → ArenaNowSection+LiveNote.swift

extension ArenaNowSection {
    var nowSectionBody: some View {
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
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ArenaNowSectionA11y.spokenSection(runCount: runs.count))
        .accessibilityIdentifier(A11yID.arenaNowSection)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: runs.map(\.id))
    }
}
