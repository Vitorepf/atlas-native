import SwiftUI
import UIKit
import AtlasCore

// Copy metrics — peel de AtlasMarkdownView+CodeBlock+Copy.
// Style → AtlasMarkdownView+CodeBlock+Copy+Style.swift

extension CodeBlockView {
    var lineCount: Int {
        guard !code.isEmpty else { return 0 }
        return code.split(separator: "\n", omittingEmptySubsequences: false).count
    }

    var canCopy: Bool { !code.isEmpty }
}
