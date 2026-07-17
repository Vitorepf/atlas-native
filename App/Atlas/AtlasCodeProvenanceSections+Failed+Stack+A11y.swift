import SwiftUI
import AtlasCore

// Failed a11y — peel de AtlasCodeProvenanceSections+Failed+Stack.

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailedA11y<Content: View>(_ content: Content, message: String) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenFailed(message))
    }
}
