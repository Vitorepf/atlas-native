import SwiftUI
import AtlasCore

// Meta author/time/law — peel de AtlasCodeCommitRow+Label.
// Hint → AtlasCodeCommitRow+Hint.swift
// Author/time → AtlasCodeCommitRow+Meta+AuthorTime.swift

extension AtlasCodeCommitRow {
    var commitMetaLine: some View {
        HStack(spacing: 6) {
            commitMetaAuthorTime
            if let ruleId {
                Text("·")
                    .accessibilityHidden(true)
                Text(AtlasCodeIssue.law(ruleId, trunk: trunk))
                    .foregroundStyle(color)
                    .accessibilityHidden(true)
            }
        }
        .font(AtlasFont.mono(9))
        .foregroundStyle(AtlasTheme.textTertiary)
    }
}
