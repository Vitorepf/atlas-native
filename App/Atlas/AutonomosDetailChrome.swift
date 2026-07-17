import SwiftUI

// Card chrome — peel de AutonomosDetailSheet (régua ~120).
// Field → AutonomosDetailChrome+Field.swift

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
}
