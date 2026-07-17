import SwiftUI
import AtlasCore

/// Linha de membro do conselho — peel de ChangeReviewCouncilSection (cena 07).
/// Meta → ChangeReviewCouncilRow+Meta.swift
/// Header → ChangeReviewCouncilRow+Header.swift

struct ChangeReviewCouncilMemberRow: View {
    let member: AtlasTraceGovernance.CouncilMember

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            providerHeader
            metaRow
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(member.spokenCouncilLine)
        .accessibilityIdentifier(A11yID.reviewCouncilMember(member.provider))
    }
}
