import SwiftUI
import AtlasCore

// Ask pill leading content — peel de AtlasCodeView+AskPillContent.
// Caption → AtlasCodeView+AskPillLeading+Caption.swift
// Trailing → AtlasCodeView+AskPillTrailing.swift

extension AtlasCodeView {
    var askPillLeading: some View {
        HStack(spacing: 10) {
            askPillCaptionStack
            askPillClearButton
            askPillTrailingChevron
        }
    }
}
