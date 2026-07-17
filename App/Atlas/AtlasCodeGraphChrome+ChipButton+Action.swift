import SwiftUI
import AtlasCore

// Chip action — peel de AtlasCodeGraphChrome+ChipButton.
// LabelBind → AtlasCodeGraphChrome+ChipButton+LabelBind.swift

extension AtlasCodeView {
    func graphStateChipAction(_ option: AtlasCodeGraphStateFilter) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
            graphStateFilter = option
        }
    }
}
