import SwiftUI
import AtlasCore

// Timeline rail — peel de AtlasCodeWhySheet+Rows.
// Meta → AtlasCodeWhySheet+RowMetaText.swift
// Connector → AtlasCodeWhySheet+RowConnector.swift

extension AtlasCodeWhySheet {
    func whyRowRail(isLast: Bool) -> some View {
        VStack(spacing: 0) {
            Circle()
                .fill(AtlasTheme.accent)
                .frame(width: 7, height: 7)
                .accessibilityHidden(true)
            whyRowConnector(isLast: isLast)
        }
        .padding(.top, 7)
        .accessibilityHidden(true)
    }
}
