import SwiftUI
import AtlasCore

// Status trailing do council header — peel de ChangeReviewCouncilRow+Header.

extension ChangeReviewCouncilMemberRow {
    var providerStatus: some View {
        Text(member.status)
            .font(AtlasFont.mono(9))
            .foregroundStyle(member.succeeded ? Color(hex: 0x83B46D) : Color(hex: 0xE08C8C))
            .accessibilityHidden(true)
    }
}
