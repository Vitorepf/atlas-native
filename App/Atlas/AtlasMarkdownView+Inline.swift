import SwiftUI
import AtlasCore

// Inline spans — peel de AtlasMarkdownView+Rendering (régua ≤100).
// Plain → AtlasMarkdownView+Plain.swift
// Mark → AtlasMarkdownView+InlineMark.swift

extension AtlasMarkdownView {
    func inline(_ spans: [InlineSpan], base: InlineBase) -> AttributedString {
        var out = AttributedString()
        for span in spans {
            out.append(inlineMark(span, base: base))
        }
        return out
    }
}
