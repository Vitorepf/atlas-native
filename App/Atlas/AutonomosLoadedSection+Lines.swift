import SwiftUI
import AtlasCore

// Info line — peel de AutonomosLoadedSection.
// Receipt/error → AutonomosLoadedSection+ReceiptCards.swift

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
        Text(text)
            .font(.footnote).foregroundStyle(AtlasTheme.textSecondary)
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .atlasCard(cornerRadius: 12)
            .accessibilityLabel(spokenLabel)
            .accessibilityAddTraits(.isStaticText)
            .modifier(OptionalA11yIdentifier(identifier))
    }
}

private struct OptionalA11yIdentifier: ViewModifier {
    let identifier: String?

    func body(content: Content) -> some View {
        if let identifier {
            content.accessibilityIdentifier(identifier)
        } else {
            content
        }
    }
}
