import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: markdown render host (was View* peels; file not route shell)

// MARK: - AtlasMarkdownView

struct AtlasMarkdownView: View {
    let text: String
    var streaming: Bool = false

    // O corpo da resposta escala com o ajuste de texto do operador; os marks
    // derivados (bold/link) seguem pela InlineBase.typeSize.
    @Environment(\.dynamicTypeSize) var typeSize

    @State var blocks: [MarkdownBlock] = []
    @State var cachedCount: Int = -1
    @State var lastParseAt: CFAbsoluteTime = 0

    var body: some View {
        parseRefreshLifecycle(
            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(blocks.enumerated()), id: \.offset) { index, block in
                    blockView(block, index: index)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        )
    }
}
// MARK: - AtlasMarkdownSurface

// MARK: - Block dispatch

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
// MARK: - AtlasMarkdownViewBlocks

// MARK: - Host

extension AtlasMarkdownView {
    func headingDefault(_ spans: [InlineSpan]) -> some View {
        Text(inline(spans, base: .init(font: AtlasFont.sans(14, weight: .semibold, at: typeSize), size: 14, color: AtlasTheme.textPrimary, typeSize: typeSize)))
            .padding(.top, 2)
    }
}

extension AtlasMarkdownView {
    func headingOne(_ spans: [InlineSpan]) -> some View {
        Text(inline(spans, base: .init(font: AtlasFont.serif(22, .semibold), size: 22, color: AtlasTheme.textPrimary, typeSize: typeSize)))
            .padding(.top, 4)
    }
}

extension AtlasMarkdownView {
    func headingTwo(_ spans: [InlineSpan]) -> some View {
        Text(plain(spans).uppercased())
            .atlasSans(11, .medium).tracking(1.1)
            .foregroundStyle(AtlasTheme.textSecondary)
            .padding(.top, 6).padding(.bottom, 2)
    }
}

extension AtlasMarkdownView {
    func inline(_ spans: [InlineSpan], base: InlineBase) -> AttributedString {
        var out = AttributedString()
        for span in spans {
            out.append(inlineMark(span, base: base))
        }
        return out
    }
}

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

extension AtlasMarkdownView {
    func inlineTextMark(_ text: String, base: InlineBase) -> AttributedString {
        var piece = AttributedString(text)
        piece.font = base.font
        piece.foregroundColor = base.color
        return piece
    }
}

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

extension AtlasMarkdownView {
    func inlineCodeMark(_ text: String) -> AttributedString {
        var piece = AttributedString(" \(text) ")
        piece.font = AtlasFont.mono(13)
        piece.foregroundColor = AtlasTheme.textPrimary
        piece.backgroundColor = AtlasTheme.surface
        return piece
    }
}

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

extension AtlasMarkdownView {
    func inlineBoldMark(_ text: String, base: InlineBase) -> AttributedString {
        var piece = AttributedString(text)
        piece.font = AtlasFont.sans(base.size, weight: .semibold, at: base.typeSize)
        piece.foregroundColor = AtlasTheme.textPrimary
        return piece
    }
}

extension AtlasMarkdownView {
    func inlineItalicMark(_ text: String, base: InlineBase) -> AttributedString {
        var piece = AttributedString(text)
        piece.font = AtlasFont.serifItalic(base.size)
        piece.foregroundColor = base.color
        return piece
    }
}

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

// MARK: - Body

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

extension AtlasMarkdownView {
    /// Fronteira barata: parágrafo novo ou fence fechando — re-parse imediato.
    static func isBlockBoundary(_ text: String) -> Bool {
        text.hasSuffix("\n\n") || text.hasSuffix("```\n") || text.hasSuffix("```")
    }
}

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
        .accessibilityLabel(AtlasMarkdownJudgment.spokenQuote(plain(spans)))
    }
}

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

// MARK: - AtlasMarkdownBlocks

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
        .accessibilityLabel(AtlasMarkdownJudgment.spokenCopyButton(copied: copied, canCopy: canCopy))
        .accessibilityHint(AtlasMarkdownJudgment.copyHint(canCopy: canCopy))
        .accessibilityIdentifier(A11yID.markdownCodeCopy(blockIndex))
    }
}

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

extension CodeBlockView {
    var codeBlockScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(code)
                .font(AtlasFont.mono(13)).foregroundStyle(AtlasTheme.textPrimary)
                .lineSpacing(5).textSelection(.enabled)
                .padding(.horizontal, 16).padding(.bottom, 14)
                .accessibilityLabel(AtlasMarkdownJudgment.spokenBlock(lang: lang, lineCount: lineCount))
        }
    }
}

// MARK: - AtlasMarkdownSurfaceCode

// MARK: - Code blocks

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

// MARK: - AtlasMarkdownSurfaceLists

// MARK: - Lists / quotes / tables

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
        .accessibilityLabel(AtlasMarkdownJudgment.spokenListItem(ordered: ordered, index: index, plain: plain(item)))
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

// MARK: - AtlasMarkdownCodeBlockView

// MARK: - CodeBlockView

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
            if let langLabel = AtlasMarkdownJudgment.langLabel(lang: lang) {
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

// MARK: - Judgment

// MARK: - Judgment

/// Pure markdown block spoken grammar (WAVE-103).
/// Casca only — never invents plain text or language labels.
enum AtlasMarkdownJudgment {

    // MARK: List / quote

    static func spokenListItem(ordered: Bool, index: Int, plain: String) -> String {
        let trimmed = plain.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return ordered ? "item \(index + 1), vazio" : "item, vazio"
        }
        return ordered ? "item \(index + 1), \(trimmed)" : trimmed
    }

    static func spokenQuote(_ plain: String) -> String {
        let trimmed = plain.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "citação vazia" : "citação, \(trimmed)"
    }

    // MARK: Code block

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

    // MARK: Pack

    static func packFacts(
        hasList: Bool,
        hasQuote: Bool,
        hasCode: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        var kinds: [String] = []
        if hasList { kinds.append("list") }
        if hasQuote { kinds.append("quote") }
        if hasCode { kinds.append("code") }
        if kinds.isEmpty {
            absences.append("nenhum bloco estruturado no markdown deste recorte")
        } else {
            facts.append("md_block_kinds: \(kinds.joined(separator: "|"))")
        }
        return (facts, absences)
    }

    /// WAVE-174: mid-thread pack from published bubble text (parse casca · Core parser).
    static func packFacts(from text: String) -> (facts: [String], absences: [String]) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return ([], ["markdown do turno ainda vazio neste recorte"])
        }
        let blocks = AtlasMarkdown.parse(trimmed)
        var hasList = false
        var hasQuote = false
        var hasCode = false
        for block in blocks {
            switch block {
            case .list: hasList = true
            case .quote: hasQuote = true
            case .code: hasCode = true
            default: break
            }
        }
        return packFacts(hasList: hasList, hasQuote: hasQuote, hasCode: hasCode)
    }
}
