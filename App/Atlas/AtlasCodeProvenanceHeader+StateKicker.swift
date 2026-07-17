import SwiftUI
import AtlasCore

// Provenance state kicker — peel de AtlasCodeProvenanceHeader.

extension AtlasCodeProvenanceSheet {
    var headerStateKicker: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(AtlasCodePalette.color(for: state))
                .frame(width: 6, height: 6)
                .accessibilityHidden(true)
            Text(stateLabel)
                .font(.system(size: 9, weight: .bold))
                .tracking(1.4)
                .foregroundStyle(AtlasCodePalette.color(for: state))
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenStateKicker())
        .accessibilityIdentifier(A11yID.codeProvenanceState)
    }
}
