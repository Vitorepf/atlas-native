import SwiftUI
import AtlasCore

// Switch de blocos — peel de AtlasMarkdownView.
// Body → AtlasMarkdownView+BlockViewBody.swift

extension AtlasMarkdownView {
    @ViewBuilder
    func blockView(_ block: MarkdownBlock, index: Int) -> some View {
        blockViewBody(block, index: index)
    }
}
