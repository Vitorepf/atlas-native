import SwiftUI
import AtlasCore

// Empty card chrome — peel de AutonomosChrome+Empty.

extension AutonomosCardEmptyState {
    func emptyCardChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .atlasCard(cornerRadius: 12)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(caption), \(copy)")
            .accessibilityIdentifier(accessibilityIdentifier)
    }
}
