import SwiftUI
import AtlasCore

// WAVE-017 markdown

// --- AtlasMarkdownView+CodeBlock+ToolbarCopy.swift ---
extension CodeBlockView {
    @ViewBuilder
    var codeBlockCopyButton: some View {
        Button(action: copyCode) {
            Text(copyButtonTitle)
                .font(AtlasFont.mono(11))
                .foregroundStyle(copyForeground)
        }
        .buttonStyle(.plain)
        .disabled(!canCopy)
        .accessibilityLabel(MarkdownCodeBlockA11y.spokenCopyButton(copied: copied, canCopy: canCopy))
        .accessibilityHint(MarkdownCodeBlockA11y.copyHint(canCopy: canCopy))
        .accessibilityIdentifier(A11yID.markdownCodeCopy(blockIndex))
    }
}

// --- AtlasMarkdownView+CodeBlock.swift ---
struct CodeBlockView: View {
    let code: String
    let lang: String?
    var blockIndex: Int = 0

    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var copied = false

    var body: some View {
        codeBlockShell
    }
}

// --- AtlasMarkdownView+CodeBlockScroll.swift ---
extension CodeBlockView {
    var codeBlockScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(code)
                .font(AtlasFont.mono(13)).foregroundStyle(AtlasTheme.textPrimary)
                .lineSpacing(5).textSelection(.enabled)
                .padding(.horizontal, 16).padding(.bottom, 14)
                .accessibilityLabel(MarkdownCodeBlockA11y.spokenBlock(lang: lang, lineCount: lineCount))
        }
    }
}

// --- AtlasMarkdownView+HeadingDefault.swift ---
extension AtlasMarkdownView {
    func headingDefault(_ spans: [InlineSpan]) -> some View {
        Text(inline(spans, base: .init(font: AtlasFont.sans(14, weight: .semibold, at: typeSize), size: 14, color: AtlasTheme.textPrimary, typeSize: typeSize)))
            .padding(.top, 2)
    }
}

// --- AtlasMarkdownView+HeadingOne.swift ---
extension AtlasMarkdownView {
    func headingOne(_ spans: [InlineSpan]) -> some View {
        Text(inline(spans, base: .init(font: AtlasFont.serif(22, .semibold), size: 22, color: AtlasTheme.textPrimary, typeSize: typeSize)))
            .padding(.top, 4)
    }
}

// --- AtlasMarkdownView+HeadingTwo.swift ---
extension AtlasMarkdownView {
    func headingTwo(_ spans: [InlineSpan]) -> some View {
        Text(plain(spans).uppercased())
            .atlasSans(11, .medium).tracking(1.1)
            .foregroundStyle(AtlasTheme.textSecondary)
            .padding(.top, 6).padding(.bottom, 2)
    }
}

// --- AtlasMarkdownView+Inline.swift ---
extension AtlasMarkdownView {
    func inline(_ spans: [InlineSpan], base: InlineBase) -> AttributedString {
        var out = AttributedString()
        for span in spans {
            out.append(inlineMark(span, base: base))
        }
        return out
    }
}

// --- AtlasMarkdownView+InlineMark+Fallback.swift ---
extension AtlasMarkdownView {
    func inlineMarkTextFallback(_ span: InlineSpan, base: InlineBase) -> AttributedString {
        switch span {
        case .text(let t):
            return inlineTextMark(t, base: base)
        default:
            return AttributedString()
        }
    }
}

// --- AtlasMarkdownView+InlineMark+Text.swift ---
extension AtlasMarkdownView {
    func inlineTextMark(_ text: String, base: InlineBase) -> AttributedString {
        var piece = AttributedString(text)
        piece.font = base.font
        piece.foregroundColor = base.color
        return piece
    }
}

// --- AtlasMarkdownView+InlineMark.swift ---
extension AtlasMarkdownView {
    func inlineMark(_ span: InlineSpan, base: InlineBase) -> AttributedString {
        if let decorated = inlineDecoratedMark(span, base: base) {
            return decorated
        }
        if let emphasis = inlineEmphasisMark(span, base: base) {
            return emphasis
        }
        return inlineMarkTextFallback(span, base: base)
    }
}

// --- AtlasMarkdownView+InlineMarkDecorated+Code.swift ---
extension AtlasMarkdownView {
    func inlineCodeMark(_ text: String) -> AttributedString {
        var piece = AttributedString(" \(text) ")
        piece.font = AtlasFont.mono(13)
        piece.foregroundColor = AtlasTheme.textPrimary
        piece.backgroundColor = AtlasTheme.surface
        return piece
    }
}

// --- AtlasMarkdownView+InlineMarkDecorated+Link.swift ---
extension AtlasMarkdownView {
    func inlineLinkMark(_ text: String, url: String, base: InlineBase) -> AttributedString {
        var piece = AttributedString(text)
        piece.font = AtlasFont.sans(base.size, weight: .medium, at: base.typeSize)
        piece.foregroundColor = AtlasTheme.prussian
        piece.underlineStyle = .single
        if let u = URL(string: url) { piece.link = u }
        return piece
    }
}

// --- AtlasMarkdownView+InlineMarkDecorated.swift ---
extension AtlasMarkdownView {
    func inlineDecoratedMark(_ span: InlineSpan, base: InlineBase) -> AttributedString? {
        switch span {
        case .code(let t):
            return inlineCodeMark(t)
        case .link(let t, let url):
            return inlineLinkMark(t, url: url, base: base)
        default:
            return nil
        }
    }
}

// --- AtlasMarkdownView+InlineMarkEmphasis+Bold.swift ---
extension AtlasMarkdownView {
    func inlineBoldMark(_ text: String, base: InlineBase) -> AttributedString {
        var piece = AttributedString(text)
        piece.font = AtlasFont.sans(base.size, weight: .semibold, at: base.typeSize)
        piece.foregroundColor = AtlasTheme.textPrimary
        return piece
    }
}

// --- AtlasMarkdownView+InlineMarkEmphasis+Italic.swift ---
extension AtlasMarkdownView {
    func inlineItalicMark(_ text: String, base: InlineBase) -> AttributedString {
        var piece = AttributedString(text)
        piece.font = AtlasFont.serifItalic(base.size)
        piece.foregroundColor = base.color
        return piece
    }
}

// --- AtlasMarkdownView+InlineMarkEmphasis.swift ---
extension AtlasMarkdownView {
    func inlineEmphasisMark(_ span: InlineSpan, base: InlineBase) -> AttributedString? {
        switch span {
        case .bold(let t):
            return inlineBoldMark(t, base: base)
        case .italic(let t):
            return inlineItalicMark(t, base: base)
        default:
            return nil
        }
    }
}

// --- AtlasMarkdownView+ListMarker.swift ---
extension AtlasMarkdownView {
    @ViewBuilder
    func listItemMarker(ordered: Bool, index: Int) -> some View {
        if ordered {
            Text("\(index + 1).")
                .font(AtlasFont.mono(13)).foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 26, alignment: .leading).padding(.top, 3)
                .accessibilityHidden(true)
        } else {
            Text("—")
                .atlasSans(16).foregroundStyle(AtlasTheme.accent)
                .frame(width: 22, alignment: .leading)
                .accessibilityHidden(true)
        }
    }
}

// --- AtlasMarkdownView+Parse.swift ---
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
}

// --- AtlasMarkdownView+ParseBoundary.swift ---
extension AtlasMarkdownView {
    /// Fronteira barata: parágrafo novo ou fence fechando — re-parse imediato.
    static func isBlockBoundary(_ text: String) -> Bool {
        text.hasSuffix("\n\n") || text.hasSuffix("```\n") || text.hasSuffix("```")
    }
}

// --- AtlasMarkdownView+ParseRefresh.swift ---
extension AtlasMarkdownView {
    func parseRefreshLifecycle<Content: View>(_ content: Content) -> some View {
        content
            .onAppear { refreshBlocks(force: true) }
            .onChange(of: text) { _, _ in refreshBlocks(force: !streaming) }
            .onChange(of: streaming) { _, isStreaming in
                if !isStreaming { refreshBlocks(force: true) }
            }
    }
}

// --- AtlasMarkdownView+Plain.swift ---
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

// --- AtlasMarkdownView+Quote.swift ---
extension AtlasMarkdownView {
    @ViewBuilder
    func quoteBlock(_ spans: [InlineSpan]) -> some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 1).fill(AtlasTheme.accent).frame(width: 2)
                .accessibilityHidden(true)
            Text(inline(spans, base: .init(font: AtlasFont.serifItalic(17), size: 17, color: AtlasTheme.textPrimary, typeSize: typeSize)))
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHidden(true)
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(MarkdownBlocksA11y.spokenQuote(plain(spans)))
    }
}

// --- AtlasMarkdownView+Rendering.swift ---
extension AtlasMarkdownView {
    struct InlineBase {
        let font: Font
        let size: CGFloat
        let color: Color
        // Serif/mono escalam sozinhos (relativeTo); o sans dos marks precisa
        // da categoria para escalar junto.
        var typeSize: DynamicTypeSize = .large
    }

    @ViewBuilder
    func heading(_ level: Int, _ spans: [InlineSpan]) -> some View {
        switch level {
        case 1: headingOne(spans)
        case 2: headingTwo(spans)
        default: headingDefault(spans)
        }
    }
}

// --- AtlasMarkdownView+Table+DataRows.swift ---
extension AtlasMarkdownView {
    @ViewBuilder
    func tableDataRows(_ rows: [[[InlineSpan]]], colCount: Int) -> some View {
        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
            HStack(spacing: 0) {
                ForEach(0..<colCount, id: \.self) { ci in
                    Text(inline(ci < row.count ? row[ci] : [], base: .init(font: AtlasFont.sans(14, weight: .regular, at: typeSize), size: 14, color: AtlasTheme.textPrimary, typeSize: typeSize)))
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 8)
                }
            }
            .padding(.vertical, 12)
            .overlay(alignment: .bottom) { Rectangle().fill(AtlasTheme.separatorSoft).frame(height: 1) }
        }
    }
}

// --- AtlasMarkdownView+Table.swift ---
extension AtlasMarkdownView {
    func tableView(_ headers: [[InlineSpan]], _ rows: [[[InlineSpan]]]) -> some View {
        let colCount = max(headers.count, rows.map { $0.count }.max() ?? 0)
        return VStack(spacing: 0) {
            tableHeaderRow(headers, colCount: colCount)
            tableDataRows(rows, colCount: colCount)
        }
        .overlay(alignment: .top) { Rectangle().fill(AtlasTheme.separator).frame(height: 1) }
    }
}

// --- AtlasMarkdownView+TableHeader.swift ---
extension AtlasMarkdownView {
    func tableHeaderRow(_ headers: [[InlineSpan]], colCount: Int) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<colCount, id: \.self) { ci in
                Text(plain(ci < headers.count ? headers[ci] : []).uppercased())
                    .font(AtlasFont.mono(10, .medium)).tracking(1.4)
                    .foregroundStyle(AtlasTheme.accent)
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 8)
            }
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) { Rectangle().fill(AtlasTheme.separator).frame(height: 1) }
    }
}

