import SwiftUI
import AtlasCore

/// Linha de membro do conselho — peel de ChangeReviewCouncilSection (cena 07).
/// Meta → ChangeReviewCouncilRow+Meta.swift

struct ChangeReviewCouncilMemberRow: View {
    let member: AtlasTraceGovernance.CouncilMember

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
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
                Text(member.status)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(member.succeeded ? Color(hex: 0x83B46D) : Color(hex: 0xE08C8C))
                    .accessibilityHidden(true)
            }
            metaRow
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(member.spokenCouncilLine)
        .accessibilityIdentifier(A11yID.reviewCouncilMember(member.provider))
    }
}
