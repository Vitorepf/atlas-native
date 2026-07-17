import SwiftUI
import AtlasCore

// Domain unavailable card — peel de AtlasArenaView+States.

extension AtlasArenaView {
    var domainUnavailableCard: some View {
        Text(ArenaModel.domainUnavailableCopy)
            .font(.system(.subheadline))
            .foregroundStyle(AtlasTheme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .atlasCard()
            .accessibilityElement(children: .combine)
            .accessibilityLabel(domainUnavailableSpoken)
            .accessibilityHint(domainUnavailableHint)
    }
}
