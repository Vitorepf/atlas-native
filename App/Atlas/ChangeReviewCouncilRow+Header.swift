import SwiftUI
import AtlasCore

// Provider header line — peel de ChangeReviewCouncilRow.
// Status → ChangeReviewCouncilRow+HeaderStatus.swift

extension ChangeReviewCouncilMemberRow {
    var providerHeader: some View {
        HStack(spacing: 7) {
            Image(systemName: member.succeeded ? "checkmark" : "xmark")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(member.succeeded ? Color(hex: 0x83B46D) : Color(hex: 0xE08C8C))
                .accessibilityHidden(true)
            Text(member.provider)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
            if let model = member.model {
                Text(model)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .accessibilityHidden(true)
            }
            Spacer()
            providerStatus
        }
    }
}
