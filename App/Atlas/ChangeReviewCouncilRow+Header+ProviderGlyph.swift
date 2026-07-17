import SwiftUI
import AtlasCore

// Provider glyph — peel de ChangeReviewCouncilRow+Header.

extension ChangeReviewCouncilMemberRow {
    var providerOutcomeGlyph: some View {
        Image(systemName: member.succeeded ? "checkmark" : "xmark")
            .font(.system(size: 9, weight: .semibold))
            .foregroundStyle(member.succeeded ? Color(hex: 0x83B46D) : Color(hex: 0xE08C8C))
            .accessibilityHidden(true)
    }
}
