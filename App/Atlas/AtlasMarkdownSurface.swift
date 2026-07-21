import SwiftUI
import AtlasCore

// WAVE-017 markdown

extension AtlasMarkdownView {
    @ViewBuilder
    func blockView(_ block: MarkdownBlock, index: Int) -> some View {
        blockViewBody(block, index: index)
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewBody(_ block: MarkdownBlock, index: Int) -> some View {
        switch block {
        case .paragraph, .heading:
            blockViewInline(block)
        case .list, .quote, .code, .divider, .table:
            blockViewStructural(block, index: index)
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewInline(_ block: MarkdownBlock) -> some View {
        switch block {
        case .paragraph(let spans):
            Text(inline(spans, base: .init(font: AtlasFont.sans(16, weight: .regular, at: typeSize), size: 16, color: AtlasTheme.textPrimary, typeSize: typeSize)))
                .lineSpacing(6)
        case .heading(let level, let spans):
            heading(level, spans)
        default:
            EmptyView()
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewCodeBlock(_ block: MarkdownBlock, index: Int) -> some View {
        if case .code(let codeText, let lang) = block {
            CodeBlockView(code: codeText, lang: lang, blockIndex: index)
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewStructuralCode(_ block: MarkdownBlock, index: Int) -> some View {
        if case .code = block {
            blockViewCodeBlock(block, index: index)
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewStructuralCodeTable(_ block: MarkdownBlock, index: Int) -> some View {
        switch block {
        case .code:
            blockViewStructuralCode(block, index: index)
        case .divider:
            blockViewDividerBlock
        case .table:
            blockViewTableBlock(block)
        default:
            EmptyView()
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    var blockViewDividerBlock: some View {
        Rectangle().fill(AtlasTheme.separator).frame(height: 1).padding(.vertical, 2)
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewListBlock(_ block: MarkdownBlock) -> some View {
        if case .list(let ordered, let items) = block {
            listBlock(ordered: ordered, items: items)
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewStructuralListQuote(_ block: MarkdownBlock, index: Int) -> some View {
        switch block {
        case .list:
            blockViewListBlock(block)
        case .quote:
            blockViewQuoteBlock(block)
        default:
            EmptyView()
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewQuoteBlock(_ block: MarkdownBlock) -> some View {
        if case .quote(let spans) = block {
            quoteBlock(spans)
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewTableBlock(_ block: MarkdownBlock) -> some View {
        if case .table(let headers, let rows) = block {
            tableView(headers, rows)
        }
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func blockViewStructural(_ block: MarkdownBlock, index: Int) -> some View {
        switch block {
        case .list, .quote:
            blockViewStructuralListQuote(block, index: index)
        case .code, .divider, .table:
            blockViewStructuralCodeTable(block, index: index)
        default:
            EmptyView()
        }
    }
}

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

extension AtlasMarkdownView {
    @ViewBuilder
    func listBlockItem(ordered: Bool, index: Int, item: [InlineSpan]) -> some View {
        HStack(alignment: .top, spacing: 0) {
            listItemMarker(ordered: ordered, index: index)
            Text(inline(item, base: .init(font: AtlasFont.sans(16, weight: .regular, at: typeSize), size: 16, color: AtlasTheme.textPrimary, typeSize: typeSize)))
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(MarkdownBlocksA11y.spokenListItem(ordered: ordered, index: index, plain: plain(item)))
    }
}

extension AtlasMarkdownView {
    @ViewBuilder
    func listBlock(ordered: Bool, items: [[InlineSpan]]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                listBlockItem(ordered: ordered, index: idx, item: item)
            }
        }
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

extension CodeBlockView {
    var codeBlockBackground: some View {
        RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.surface)
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).stroke(AtlasTheme.separator, lineWidth: 1))
    }
}

extension CodeBlockView {
    var lineCount: Int {
        guard !code.isEmpty else { return 0 }
        return code.split(separator: "\n", omittingEmptySubsequences: false).count
    }

    var canCopy: Bool { !code.isEmpty }
}

extension CodeBlockView {
    var copyButtonTitle: String {
        guard canCopy else { return "copiar" }
        return copied ? "copiado" : "copiar"
    }

    var copyForeground: Color {
        guard canCopy else { return AtlasTheme.textTertiary.opacity(0.5) }
        return copied ? AtlasTheme.accent : AtlasTheme.textSecondary
    }
}

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

extension CodeBlockView {
    @ViewBuilder
    var codeBlockShellFrame: some View {
        codeBlockShellStack
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(codeBlockBackground)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.markdownCodeBlock(blockIndex))
    }
}

extension CodeBlockView {
    @ViewBuilder
    var codeBlockShellStack: some View {
        VStack(alignment: .leading, spacing: 0) {
            codeBlockToolbar
            codeBlockScroll
        }
    }
}

extension CodeBlockView {
    var codeBlockShell: some View {
        codeBlockShellFrame
    }
}

extension CodeBlockView {
    var codeBlockToolbar: some View {
        HStack {
            if let langLabel = MarkdownCodeBlockA11y.langLabel(lang: lang) {
                Text(langLabel)
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            Spacer()
            codeBlockCopyButton
        }
        .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 8)
    }
}

