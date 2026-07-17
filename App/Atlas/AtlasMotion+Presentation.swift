import SwiftUI

// Helpers de apresentação — peel de AtlasMotion (régua ≤100).

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

enum AtlasMotionPresentation {
    /// Transição editorial condicional — nil com Reduce Motion.
    static func editorial(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : AtlasMotion.editorial
    }

    /// Identidade com Reduce Motion; editorial caso contrário.
    static func rowTransition(reduceMotion: Bool) -> AnyTransition {
        reduceMotion ? .identity : .opacity.combined(with: .move(edge: .top))
    }
}

extension View {
    func atlasNumericTransition(reduceMotion: Bool) -> some View {
        modifier(NumericTextTransition(enabled: !reduceMotion))
    }
}
