import SwiftUI
import AtlasCore

// Card chrome — peel de ExecutionStateCard.

extension ExecutionStateCard {
    func stateCardChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(AtlasTheme.surface.opacity(0.68))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(tint.opacity(0.42), lineWidth: 1))
            )
            .accessibilityElement(children: .contain)
            .accessibilityLabel(spokenSummary)
            .accessibilityIdentifier(A11yID.executionStateCard)
    }
}
