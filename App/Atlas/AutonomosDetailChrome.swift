import SwiftUI

// Card/field chrome — peel de AutonomosDetailSheet (régua ~120).

enum AutonomosDetailChrome {
    static func card<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.footnote, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            content()
        }
        .padding(14)
        .atlasCard(cornerRadius: 12)
        .accessibilityElement(children: .contain)
    }

    static func field(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(label)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(width: 112, alignment: .leading)
                .accessibilityHidden(true)
            Text(value.isEmpty ? "—" : value)
                .font(.caption)
                .foregroundStyle(AtlasTheme.textSecondary)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AutonomosDetailChromeA11y.spokenField(label: label, value: value))
    }
}
