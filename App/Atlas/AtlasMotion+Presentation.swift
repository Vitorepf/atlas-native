import SwiftUI

// Helpers de apresentação — peel de AtlasMotion (régua ≤100).
// Helpers → AtlasMotion+PresentationHelpers.swift

/// Numeric text morph só quando Reduce Motion está desligado.
struct NumericTextTransition: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.contentTransition(.numericText())
        } else {
            content
        }
    }
}
