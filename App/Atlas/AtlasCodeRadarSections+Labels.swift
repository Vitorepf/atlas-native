import AtlasCore
import SwiftUI

// Labels + divider — peel de AtlasCodeRadarSections.

struct AtlasCodeRadarSectionLabel: View {
    let text: String
    var accessibilityID: String? = nil

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .tracking(1.3)
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier(accessibilityID ?? text)
    }
}

struct AtlasCodeRadarRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(AtlasTheme.separator.opacity(0.5))
            .frame(height: 0.5)
    }
}
