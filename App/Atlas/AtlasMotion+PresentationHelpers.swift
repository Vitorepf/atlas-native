import SwiftUI

// Motion presentation helpers — peel de AtlasMotion+Presentation.

@MainActor
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
