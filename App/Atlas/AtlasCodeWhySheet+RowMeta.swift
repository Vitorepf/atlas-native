import SwiftUI
import AtlasCore

// Timeline rail — peel de AtlasCodeWhySheet+Rows.
// Meta → AtlasCodeWhySheet+RowMetaText.swift

extension AtlasCodeWhySheet {
    func whyRowRail(isLast: Bool) -> some View {
        VStack(spacing: 0) {
            Circle()
                .fill(AtlasTheme.accent)
                .frame(width: 7, height: 7)
                .accessibilityHidden(true)
            if !isLast {
                Rectangle()
                    .fill(AtlasTheme.accent.opacity(0.35))
                    .frame(width: 1)
                    .frame(minHeight: 56)
                    .accessibilityHidden(true)
            }
        }
        .padding(.top, 7)
        .accessibilityHidden(true)
    }
}
