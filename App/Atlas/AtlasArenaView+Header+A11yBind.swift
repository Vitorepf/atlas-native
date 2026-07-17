import SwiftUI
import AtlasCore

// Header a11y bind — peel de AtlasArenaView+Header.

extension AtlasArenaView {
    func headerA11yBound(_ column: some View) -> some View {
        column
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(headerSpokenLabel)
            .accessibilityAddTraits(.isHeader)
    }
}
