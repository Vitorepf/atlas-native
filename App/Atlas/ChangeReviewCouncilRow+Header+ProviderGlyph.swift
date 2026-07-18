import SwiftUI
import AtlasCore

// Provider glyph — peel de ChangeReviewCouncilRow+Header.

extension ChangeReviewCouncilMemberRow {
    var providerOutcomeGlyph: some View {
        Image(systemName: member.succeeded ? "checkmark" : "xmark")
            .atlasSans(9, .semibold)
            .foregroundStyle(member.succeeded ? AtlasCodePalette.healed : AtlasTheme.alert)
            .accessibilityHidden(true)
    }
}
