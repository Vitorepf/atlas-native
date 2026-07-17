import SwiftUI
import AtlasCore

// Options menu buttons — peel de ComposerToolbar+Options.
// Items → ComposerToolbar+OptionsItems.swift

extension ComposerToolbar {
    @ViewBuilder
    var optionsMenuButtons: some View {
        optionsWorkspaceButton
        optionsModeButton
        optionsEffortButton
    }
}
