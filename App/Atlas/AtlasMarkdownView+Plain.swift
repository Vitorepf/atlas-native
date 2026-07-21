import SwiftUI
import AtlasCore

// Plain text from spans — peel de AtlasMarkdownView+Inline.

extension AtlasMarkdownView {
    func plain(_ spans: [InlineSpan]) -> String {
        spans.map {
            switch $0 {
            case .text(let t), .bold(let t), .italic(let t), .code(let t): return t
            case .link(let t, _): return t
            }
        }.joined()
    }
}
