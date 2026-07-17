import SwiftUI
import AtlasCore

// Parse throttle — peel de AtlasMarkdownView.

extension AtlasMarkdownView {
    func refreshBlocks(force: Bool) {
        let count = text.count
        if count == cachedCount, !force { return }

        if !force, streaming {
            let now = CFAbsoluteTimeGetCurrent()
            let elapsed = now - lastParseAt
            if elapsed < 0.1, !Self.isBlockBoundary(text) { return }
            lastParseAt = now
        } else {
            lastParseAt = CFAbsoluteTimeGetCurrent()
        }

        cachedCount = count
        blocks = AtlasMarkdown.parse(text)
    }

    /// Fronteira barata: parágrafo novo ou fence fechando — re-parse imediato.
    static func isBlockBoundary(_ text: String) -> Bool {
        text.hasSuffix("\n\n") || text.hasSuffix("```\n") || text.hasSuffix("```")
    }
}
