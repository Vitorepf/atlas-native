import SwiftUI
import AtlasCore

// Ask pill a11y chrome — peel de AtlasCodeView+AskPillChrome.
// Traits → AtlasCodeView+AskPillA11yTraits.swift
// Tap → AtlasCodeView+AskPillA11y+Tap.swift
// PaddingAnimation → AtlasCodeView+AskPillA11y+PaddingAnimation.swift

extension AtlasCodeView {
    var askPillA11yChrome: some View {
        askPillA11yTraits(
            askPillPaddingAnimation(
                askPillTapGesture(askPillContent)
            )
        )
    }
}
