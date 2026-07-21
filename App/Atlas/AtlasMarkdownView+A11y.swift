import SwiftUI
import AtlasCore

// Cycle 022 fuse → AtlasMarkdownView+A11y.swift

/// Marcadores tipográficos são decorativos; VoiceOver lê só o conteúdo.

enum MarkdownBlocksA11y {
    static func spokenListItem(ordered: Bool, index: Int, plain: String) -> String {
        let trimmed = plain.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return ordered ? "item \(index + 1), vazio" : "item, vazio"
        }
        return ordered ? "item \(index + 1), \(trimmed)" : trimmed
    }

    static func spokenQuote(_ plain: String) -> String {
        MarkdownBlocksA11yQuote.spokenQuote(plain)
    }
}

enum MarkdownBlocksA11yQuote {
    static func spokenQuote(_ plain: String) -> String {
        let trimmed = plain.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "citação vazia" : "citação, \(trimmed)"
    }
}

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

extension MarkdownCodeBlockA11y {
    static func spokenCopyButton(copied: Bool, canCopy: Bool) -> String {
        if !canCopy { return "copiar indisponível, bloco vazio" }
        return copied ? "código copiado" : "copiar código"
    }

    static func copyHint(canCopy: Bool) -> String {
        canCopy ? "cola este bloco na área de transferência" : ""
    }

    static func langLabel(lang: String?) -> String? {
        guard let lang, !lang.isEmpty else { return nil }
        return lang.lowercased()
    }
}

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
