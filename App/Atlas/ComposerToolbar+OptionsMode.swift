import SwiftUI
import AtlasCore

// Mode options button — peel de ComposerToolbar+OptionsItems.

extension ComposerToolbar {
    var optionsModeButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onShowMode()
        } label: {
            Label("Modo: \(mode.capitalized)", systemImage: "slider.horizontal.3")
        }
        .accessibilityLabel("modo, \(mode)")
    }
}
