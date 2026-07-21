import SwiftUI
import AtlasCore

// Status trailing do council header — peel de ChangeReviewCouncilRow+Header.

extension ChangeReviewCouncilMemberRow {
    var providerStatus: some View {
        Text(member.status)
            .font(AtlasFont.mono(9))
            .foregroundStyle(member.succeeded ? AtlasCodePalette.healed : AtlasTheme.alert)
            .accessibilityHidden(true)
    }
}
