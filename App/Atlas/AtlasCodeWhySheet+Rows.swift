import SwiftUI
import AtlasCore

// Linhas da timeline de commits — peel de AtlasCodeWhySheet (régua ~120).
// Meta/rail → AtlasCodeWhySheet+RowMeta.swift
// Text → AtlasCodeWhySheet+RowText.swift

extension AtlasCodeWhySheet {
    func whyRow(_ commit: AtlasCodeWhy.Commit, index: Int, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            whyRowRail(isLast: isLast)
            whyRowText(commit, isLast: isLast)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenCommit(commit))
        .accessibilityIdentifier(A11yID.whyRow(index))
    }
}
