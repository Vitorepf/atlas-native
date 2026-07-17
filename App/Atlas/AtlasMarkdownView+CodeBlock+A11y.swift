import Foundation

// Spoken labels — peel de AtlasMarkdownView+CodeBlock (CICLO C residual honesty).
// Copy → AtlasMarkdownView+CodeBlock+A11yCopy.swift

enum MarkdownCodeBlockA11y {
    static func spokenBlock(lang: String?, lineCount: Int) -> String {
        var parts = ["bloco de código"]
        if let lang, !lang.isEmpty {
            parts.append("linguagem \(lang.lowercased())")
        } else {
            parts.append("linguagem não informada")
        }
        if lineCount == 0 {
            parts.append("vazio")
        } else {
            parts.append("\(lineCount) linha\(lineCount == 1 ? "" : "s")")
        }
        return parts.joined(separator: ", ")
    }
}
