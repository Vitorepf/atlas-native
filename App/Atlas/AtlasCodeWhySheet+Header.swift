import SwiftUI
import AtlasCore

// Header Why — peel de AtlasCodeWhySheet.
// Truncation → AtlasCodeWhySheet+HeaderTruncation.swift
// Title → AtlasCodeWhySheet+Header+TitleBlock.swift

extension AtlasCodeWhySheet {
    var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            whyHeaderTitleBlock
            headerTruncation
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(whyHeaderSpokenLabel)
    }
}
