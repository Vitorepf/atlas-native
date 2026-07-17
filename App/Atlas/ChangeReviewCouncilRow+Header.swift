import SwiftUI
import AtlasCore

// Provider header line — peel de ChangeReviewCouncilRow.
// Status → ChangeReviewCouncilRow+HeaderStatus.swift
// Model → ChangeReviewCouncilRow+HeaderModel.swift
// Glyph → ChangeReviewCouncilRow+Header+ProviderGlyph.swift

extension ChangeReviewCouncilMemberRow {
    var providerHeader: some View {
        HStack(spacing: 7) {
            providerOutcomeGlyph
            Text(member.provider)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
            providerModelLabel
            Spacer()
            providerStatus
        }
    }
}
