import SwiftUI
import AtlasCore

// Ask button label — peel de AtlasCodeProvenanceSections+Ask.
// Lead → AtlasCodeProvenanceSections+AskLabel+Lead.swift
// Trailing → AtlasCodeProvenanceSections+AskLabel+Trailing.swift

extension AtlasCodeProvenanceSheet {
    var askButtonLabel: some View {
        HStack(spacing: 8) {
            askButtonLabelLead
            askButtonLabelTrailing
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .atlasCard(cornerRadius: AtlasTheme.Radius.control)
        .contentShape(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
    }
}
