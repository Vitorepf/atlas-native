import SwiftUI
import UIKit
import AtlasCore

// Copy action — peel de AtlasMarkdownView+CodeBlock+Copy.

extension CodeBlockView {
    func copyCode() {
        guard canCopy else { return }
        UIPasteboard.general.string = code
        guard UIPasteboard.general.string == code else { return }
        AtlasMotion.lightImpact(reduceMotion: reduceMotion)
        setCopied(true)
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            setCopied(false)
        }
    }

    func setCopied(_ value: Bool) {
        if reduceMotion { copied = value }
        else { withAnimation(AtlasMotion.editorial) { copied = value } }
    }
}
