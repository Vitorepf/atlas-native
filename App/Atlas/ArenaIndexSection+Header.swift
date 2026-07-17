import SwiftUI
import AtlasCore

// Header — peel de ArenaIndexSection.
// Captions → ArenaIndexSection+Captions.swift
// Weights → ArenaIndexSection+HeaderWeights.swift · Title → +HeaderTitle.swift

extension ArenaIndexSection {
    var sectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            sectionHeaderTitle
            Spacer()
            sectionHeaderWeights
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(sectionSpokenLabel)
    }
}
