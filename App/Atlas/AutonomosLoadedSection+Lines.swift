import SwiftUI
import AtlasCore

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

struct AutonomosControlReceiptLine: View {
    let receipt: AtlasAutonomosRunControlResponse

    var body: some View {
        Text(receipt.note)
            .font(.footnote).foregroundStyle(AtlasTheme.textSecondary)
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.domAutonomos.opacity(0.1)))
            .accessibilityLabel(AutonomosLoadedSectionA11y.spokenControlReceipt(receipt))
            .accessibilityAddTraits(.isStaticText)
            .accessibilityIdentifier(A11yID.autonomosControlReceipt)
    }
}

struct AutonomosErrorCard: View {
    let message: String

    var body: some View {
        Text(message).font(.footnote).foregroundStyle(AtlasTheme.domOperacional)
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.domOperacional.opacity(0.1)))
            .accessibilityLabel(AutonomosLoadedSectionA11y.spokenControlError(message))
            .accessibilityAddTraits(.isStaticText)
            .accessibilityIdentifier(A11yID.autonomosControlError)
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
