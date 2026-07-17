import SwiftUI
import AtlasCore

// Info line — peel de AutonomosLoadedSection.
// Receipt/error → AutonomosLoadedSection+ReceiptCards.swift
// Optional a11y → AutonomosLoadedSection+OptionalA11y.swift

struct AutonomosInfoLine: View {
    let text: String
    let spokenLabel: String
    let identifier: String?

    init(_ text: String, spokenLabel: String? = nil, identifier: String? = nil) {
        self.text = text
        self.spokenLabel = spokenLabel ?? text
        self.identifier = identifier
    }

    var body: some View {
        infoLineCard(text)
            .accessibilityLabel(spokenLabel)
            .accessibilityAddTraits(.isStaticText)
            .modifier(OptionalA11yIdentifier(identifier))
    }
}
