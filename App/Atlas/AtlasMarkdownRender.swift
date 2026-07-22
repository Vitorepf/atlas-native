import SwiftUI
import AtlasCore
import WidgetKit

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
        Button(action: copyCodeToClipboard) {
            Text(copyButtonTitle)
                .font(AtlasFont.mono(11))
                .foregroundStyle(copyForeground)
        }
        .buttonStyle(.plain)
        .disabled(!canCopy)
        .accessibilityLabel(AtlasMarkdownJudgment.spokenCopyButton(copied: copied, canCopy: canCopy))
        .accessibilityHint(AtlasMarkdownJudgment.spokenCopyHint(canCopy: canCopy))
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
    func copyCodeToClipboard() {
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
            if let langLabel = AtlasMarkdownJudgment.productLang(lang: lang) {
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

/// Pure markdown block spoken grammar (WAVE-103).
/// Casca only — never invents plain text or language labels.
enum AtlasMarkdownJudgment {

    static func productCycleOutcome(index: Int, outcome: String) -> String {
        "ciclo \(index) · \(outcome)"
    }

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

    static func spokenCopyHint(canCopy: Bool) -> String {
        canCopy ? "cola este bloco na área de transferência" : ""
    }

    static func productLang(lang: String?) -> String? {
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

// MARK: - AtlasOpsFailureJudgment

// MARK: - Judgment

// MARK: - Types

/// Exclusive shared ops-failure face (WAVE-080).
enum AtlasOpsFailureFace: Equatable {
    case network
    case domain
    case load

    var productWord: String {
        switch self {
        case .network: return "network"
        case .domain: return "domain"
        case .load: return "load"
        }
    }

    var spokenFace: String {
        switch self {
        case .network: return "falha de rede"
        case .domain: return "domínio não publicado"
        case .load: return "falha ao carregar"
        }
    }
}

// MARK: - Judgment

/// Pure ops-failure grammar — face · copy · retry · pack.
enum AtlasOpsFailureJudgment {

    static let domainHeadline = "A medição ainda não existe neste servidor"
    static let domainFootnote = "Nenhum índice, progresso ou resultado foi presumido."
    static let productDomainKicker = "Arena não publicada"
    static let productRetryCentered = "Tentar de novo"
    static let productRetryEditorial = "Tentar novamente"
    static let retrySpoken = "tentar de novo"

    static func face(mode: AtlasOpsFailureMode) -> AtlasOpsFailureFace {
        switch mode {
        case .network: return .network
        case .domainUnavailable: return .domain
        case .load: return .load
        }
    }

    static func headline(mode: AtlasOpsFailureMode) -> String {
        switch mode {
        case .network(let kind, let hasToken, _):
            return AtlasFailureCopy.headline(kind: kind, hasToken: hasToken)
        case .domainUnavailable:
            return domainHeadline
        case .load(let headline, _):
            return headline
        }
    }

    static func footnote(mode: AtlasOpsFailureMode) -> String? {
        switch mode {
        case .network(let kind, let hasToken, _):
            return AtlasFailureCopy.productHint(kind: kind, hasToken: hasToken)
        case .domainUnavailable:
            return domainFootnote
        case .load(_, let message):
            return message.isEmpty ? nil : message
        }
    }

    static func productDefaultKicker(mode: AtlasOpsFailureMode) -> String? {
        if case .domainUnavailable = mode { return productDomainKicker }
        return nil
    }

    static func defaultSymbol(mode: AtlasOpsFailureMode) -> String {
        switch mode {
        case .network: return "wifi.exclamationmark"
        case .domainUnavailable: return "shippingbox"
        case .load: return "exclamationmark.triangle"
        }
    }

    static func showsRetry(mode: AtlasOpsFailureMode) -> Bool {
        switch mode {
        case .network(_, let hasToken, _): return hasToken
        case .domainUnavailable, .load: return true
        }
    }

    static func spokenLabel(
        mode: AtlasOpsFailureMode,
        kicker: String?,
        spokenOverride: String?
    ) -> String {
        if let spokenOverride { return spokenOverride }
        var parts: [String] = []
        let resolvedKicker = kicker ?? productDefaultKicker(mode: mode)
        if let k = resolvedKicker { parts.append(k) }
        parts.append(headline(mode: mode))
        if let footnote = footnote(mode: mode) {
            parts.append(footnote.replacingOccurrences(of: "\n\n", with: ". "))
        }
        return parts.joined(separator: ". ")
    }

    static func packFacts(mode: AtlasOpsFailureMode) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(mode: mode)
        facts.append("ops_failure_face: \(face.productWord)")
        switch mode {
        case .network(_, let hasToken, let host):
            facts.append("ops_failure_host: \(host)")
            facts.append("ops_failure_has_token: \(hasToken)")
            absences.append("superfície offline ou sem token")
        case .domainUnavailable:
            absences.append("domínio não publicado — sem inventar scores")
        case .load(let headline, let message):
            facts.append("ops_failure_headline: \(headline)")
            if !message.isEmpty {
                facts.append("ops_failure_message: \(message)")
            }
            absences.append("load falhou com mensagem do host")
        }
        return (facts, absences)
    }
}

// MARK: - Empty chrome

// MARK: - Ops failure canon (WAVE-008)
// Uma máquina de layout/retry/a11y para Home · Search · Conversation · Code ·
// Arena · Autônomos. Domain-unavailable ≠ offline; fail ≠ empty idle.

/// Modo da falha ops — slots, não famílias paralelas.
enum AtlasOpsFailureMode: Equatable {
    /// Rede / token — voz via `AtlasFailureCopy`.
    case network(kind: AtlasNetworkFailureKind?, hasToken: Bool, host: String)
    /// Domínio não publicado (ex.: Arena) — proíbe inventar índices/scores.
    case domainUnavailable
    /// Load falhou com headline+message do host (Code / Autônomos).
    case load(headline: String, message: String)
}

enum AtlasOpsFailureLayout: Equatable {
    case centered
    /// Arena Premium — alinhamento leading editorial, tipografia maior.
    case leadingEditorial
}

/// Primitiva única de falha ops. Hosts só passam mode + a11y + retry.
struct AtlasOpsFailureEmpty: View {
    let mode: AtlasOpsFailureMode
    var layout: AtlasOpsFailureLayout = .centered
    var kicker: String? = nil
    var symbol: String? = nil
    var topPadding: CGFloat = 56
    var accessibilityIdentifier: String
    var retryAccessibilityIdentifier: String? = nil
    var retryHint: String = "tentar de novo"
    var spokenOverride: String? = nil
    var onRetry: (() -> Void)? = nil
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            switch layout {
            case .centered:
                centeredBody
            case .leadingEditorial:
                leadingBody
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(accessibilityIdentifier)
        .accessibilityLabel(spokenLabel)
        .accessibilityValue(AtlasOpsFailureJudgment.face(mode: mode).productWord)
    }

    // MARK: - Layouts

    private var centeredBody: some View {
        VStack(spacing: 0) {
            if let resolvedKicker {
                Text(resolvedKicker.uppercased())
                    .font(AtlasFont.mono(10, .semibold))
                    .tracking(1.2)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.bottom, 12)
                    .accessibilityHidden(true)
            }
            glyph
            Spacer().frame(height: 22)
            Text(headline)
                .font(AtlasFont.serif(22, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
            centeredFootnoteBlock
            if showsRetry, onRetry != nil {
                Spacer().frame(height: 28)
                retryControl
            }
        }
        .padding(.horizontal, 44)
        .padding(.top, topPadding)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var centeredFootnoteBlock: some View {
        switch mode {
        case .network(let kind, let hasToken, let host):
            Spacer().frame(height: 12)
            Text(hasToken ? "\(host):3737" : "ATLAS_TOKEN · Secrets.xcconfig")
                .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer().frame(height: 16)
            Text(AtlasFailureCopy.productHint(kind: kind, hasToken: hasToken))
                .font(.system(.subheadline)).lineSpacing(5)
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
        case .domainUnavailable, .load:
            if let footnote {
                Spacer().frame(height: 12)
                Text(footnote)
                    .font(footnoteFont)
                    .foregroundStyle(footnoteColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityHidden(true)
            }
        }
    }

    private var leadingBody: some View {
        VStack(alignment: .leading, spacing: 18) {
            glyph
            if let resolvedKicker {
                Text(resolvedKicker)
                    .font(AtlasFont.mono(11))
                    .tracking(1.2)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            Text(headline)
                .font(AtlasFont.serif(28, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
            if let footnote {
                Text(footnote)
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityHidden(true)
            }
            if showsRetry, onRetry != nil {
                retryControl
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 22)
    }

    // MARK: - Content resolution

    /// WAVE-080: headline/footnote/spoken from AtlasOpsFailureJudgment.
    private var headline: String {
        AtlasOpsFailureJudgment.headline(mode: mode)
    }

    private var footnote: String? {
        AtlasOpsFailureJudgment.footnote(mode: mode)
    }

    private var footnoteFont: Font {
        switch mode {
        case .network: return .system(.subheadline)
        case .domainUnavailable: return AtlasFont.serifItalic(16)
        case .load: return AtlasFont.mono(11)
        }
    }

    private var footnoteColor: Color {
        switch mode {
        case .network: return AtlasTheme.textSecondary
        case .domainUnavailable: return AtlasTheme.textSecondary
        case .load: return AtlasTheme.textTertiary
        }
    }

    private var resolvedSymbol: String {
        symbol ?? AtlasOpsFailureJudgment.defaultSymbol(mode: mode)
    }

    private var resolvedKicker: String? {
        kicker ?? AtlasOpsFailureJudgment.productDefaultKicker(mode: mode)
    }

    private var showsRetry: Bool {
        AtlasOpsFailureJudgment.showsRetry(mode: mode)
    }

    private var spokenLabel: String {
        AtlasOpsFailureJudgment.spokenLabel(
            mode: mode,
            kicker: kicker,
            spokenOverride: spokenOverride
        )
    }

    // MARK: - Pieces

    @ViewBuilder
    private var glyph: some View {
        switch mode {
        case .network:
            Text("✦")
                .font(AtlasFont.serif(28))
                .foregroundStyle(AtlasTheme.accent.opacity(0.55))
                .accessibilityHidden(true)
        case .domainUnavailable, .load:
            Image(systemName: resolvedSymbol)
                .atlasSans(layout == .leadingEditorial ? 28 : 24)
                .foregroundStyle(layout == .leadingEditorial ? AtlasTheme.textTertiary : AtlasTheme.accent.opacity(0.85))
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private var retryControl: some View {
        if let onRetry {
            let button = Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onRetry()
            } label: {
                Text(layout == .leadingEditorial
                     ? AtlasOpsFailureJudgment.productRetryEditorial
                     : AtlasOpsFailureJudgment.productRetryCentered)
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.accent)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 10)
                    .background(
                        Capsule().fill(AtlasTheme.goldVeil)
                            .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1))
                    )
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel(AtlasOpsFailureJudgment.retrySpoken)
            .accessibilityHint(retryHint)

            if let retryAccessibilityIdentifier {
                button.accessibilityIdentifier(retryAccessibilityIdentifier)
            } else {
                button
            }
        }
    }
}

// MARK: - Copy

extension AtlasFailureCopy {
    static func authServerHeadline(kind: AtlasNetworkFailureKind) -> String {
        switch kind {
        case .unauthorized: return "A chave do Atlas foi recusada."
        case .maintenance: return "Atlas está em manutenção."
        case .serverUnavailable: return "O servidor está indisponível."
        default: return "O servidor está fora de alcance."
        }
    }
}

extension AtlasFailureCopy {
    static func spokenAuthServerHint(kind: AtlasNetworkFailureKind) -> String {
        switch kind {
        case .unauthorized: return "O ATLAS_TOKEN mudou no servidor. Atualize o Secrets.xcconfig e reinstale."
        case .maintenance: return "O servidor pediu uma pausa via Retry-After. O app aguarda você tentar de novo quando a janela terminar."
        case .serverUnavailable: return "O servidor respondeu, mas está fora do ar. Veja os logs no Mac."
        default: return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        }
    }
}

extension AtlasFailureCopy {
    static func spokenNetworkOfflineHint(kind: AtlasNetworkFailureKind) -> String? {
        switch kind {
        case .offline: return "Sem rede no iPhone. O Atlas volta sozinho assim que a conexão voltar."
        case .timedOut: return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        default: return nil
        }
    }
}

extension AtlasFailureCopy {
    static func spokenNetworkHint(kind: AtlasNetworkFailureKind) -> String? {
        if let offline = spokenNetworkOfflineHint(kind: kind) { return offline }
        switch kind {
        case .connectionRefused: return "No Mac, suba o servidor: o container atlas-backend parou."
        case .connectionLost: return "Instabilidade momentânea — tentar de novo costuma resolver."
        default: return nil
        }
    }
}

extension AtlasFailureCopy {
    static func productHint(kind: AtlasNetworkFailureKind?, hasToken: Bool) -> String {
        guard hasToken else { return "Configure o token no Mac e reinstale — nada foi perdido." }
        guard let kind else {
            return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        }
        return spokenNetworkHint(kind: kind) ?? spokenAuthServerHint(kind: kind)
    }
}

extension AtlasFailureCopy {
    static func networkOfflineHeadline(kind: AtlasNetworkFailureKind) -> String? {
        switch kind {
        case .offline: return "Você está sem internet."
        case .timedOut: return "O Mac não respondeu a tempo."
        default: return nil
        }
    }
}

extension AtlasFailureCopy {
    static func networkHeadline(kind: AtlasNetworkFailureKind) -> String? {
        if let offline = networkOfflineHeadline(kind: kind) { return offline }
        switch kind {
        case .connectionRefused: return "O servidor do Atlas não está de pé."
        case .connectionLost: return "A conexão caiu no meio do caminho."
        default: return nil
        }
    }
}

enum AtlasFailureCopy {
    static func headline(kind: AtlasNetworkFailureKind?, hasToken: Bool) -> String {
        guard hasToken else { return "Falta a chave do Atlas." }
        guard let kind else { return "O servidor está fora de alcance." }
        return networkHeadline(kind: kind) ?? authServerHeadline(kind: kind)
    }
}

// MARK: - TraceEvidenceJudgment

// MARK: - Types

/// Exclusive trace evidence chrome face (WAVE-068).
enum TraceEvidenceFace: Equatable {
    case loading
    case unavailable

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .unavailable: return "unavailable"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading: return "consultando evidência"
        case .unavailable: return "evidência indisponível"
        }
    }
}

// MARK: - Judgment

/// Pure trace-evidence grammar — face · reason · spoken · pack.
enum TraceEvidenceJudgment {

    static func face(isLoading: Bool) -> TraceEvidenceFace {
        isLoading ? .loading : .unavailable
    }

    static func knownMissingRunReason(_ reason: String) -> String? {
        switch reason {
        case "no_workspace": return "sem workspace ligado a esta execução"
        case "no_run": return "nenhum run de engenharia vinculado"
        default: return nil
        }
    }

    static func knownUnavailableReason(_ reason: String) -> String? {
        if let missing = knownMissingRunReason(reason) { return missing }
        switch reason {
        case "multiple_runs": return "mais de um run — evidência indisponível"
        case "ambiguous_linked_runs": return "vínculo ambíguo entre runs"
        default: return nil
        }
    }

    /// Honesty: known codes → PT; else underscore→space; nil if empty.
    static func unavailableReason(_ reason: String?) -> String? {
        guard let reason, !reason.isEmpty else { return nil }
        return knownUnavailableReason(reason)
            ?? reason.replacingOccurrences(of: "_", with: " ")
    }

    static func spokenUnavailable(prefix: String, reason: String?) -> String {
        var parts = [prefix]
        if let reason = unavailableReason(reason) { parts.append(reason) }
        return parts.joined(separator: ", ")
    }

    static func spokenLoading(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? TraceEvidenceFace.loading.spokenFace : trimmed
    }

    static func packFacts(
        isLoading: Bool,
        reason: String? = nil
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(isLoading: isLoading)
        facts.append("trace_evidence_face: \(face.productWord)")
        if isLoading {
            absences.append("evidência ainda consultando")
        } else {
            absences.append("evidência indisponível neste recorte")
            if let reason, !reason.isEmpty {
                facts.append("trace_evidence_reason: \(reason)")
                if let spoken = unavailableReason(reason) {
                    facts.append("trace_evidence_reason_pt: \(spoken)")
                }
            }
        }
        return (facts, absences)
    }
}

// MARK: - Chrome

// MARK: - TraceEvidenceChrome

enum TraceEvidenceCopy {
    static func knownMissingRunReason(_ reason: String) -> String? {
        TraceEvidenceJudgment.knownMissingRunReason(reason)
    }

    static func knownUnavailableReason(_ reason: String) -> String? {
        TraceEvidenceJudgment.knownUnavailableReason(reason)
    }

    static func unavailableReason(_ reason: String?) -> String? {
        TraceEvidenceJudgment.unavailableReason(reason)
    }

    static func unavailableSpoken(prefix: String, reason: String?) -> String {
        TraceEvidenceJudgment.spokenUnavailable(prefix: prefix, reason: reason)
    }
}

struct TraceEvidenceLoading: View {
    let text: String
    let reduceMotion: Bool

    var body: some View {
        VStack(spacing: 12) {
            BreathingDiamond(size: 10, reduceMotion: reduceMotion)
            Text(text)
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(TraceEvidenceJudgment.spokenLoading(text))
        .accessibilityValue(TraceEvidenceFace.loading.productWord)
    }
}

extension TraceEvidenceUnavailable {
    @ViewBuilder
    var unavailableIconTitle: some View {
        Image(systemName: systemImage)
            .font(.title2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
        Text(title)
            .font(AtlasFont.serif(18, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .multilineTextAlignment(.center)
            .accessibilityHidden(true)
    }
}

extension TraceEvidenceUnavailable {
    @ViewBuilder
    var unavailableSubtitle: some View {
        if let subtitle, !subtitle.isEmpty {
            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
        }
    }
}

extension TraceEvidenceUnavailable {
    var unavailableStack: some View {
        VStack(spacing: 12) {
            unavailableIconTitle
            unavailableSubtitle
        }
    }
}

struct TraceEvidenceUnavailable: View {
    let title: String
    let subtitle: String?
    let identifier: String
    let spoken: String
    var systemImage: String = "doc.text"

    var body: some View {
        unavailableStack
            .padding(36)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spoken)
            .accessibilityValue(TraceEvidenceFace.unavailable.productWord)
            .accessibilityIdentifier(identifier)
    }
}

// MARK: - AtlasNativeSnapshotWriter

extension AtlasNativeSnapshotWriter {
    static func fleet(from model: AutonomosModel) -> AtlasNativeSnapshot.Fleet? {
        guard model.taskHealth != nil || model.delivered != nil else { return nil }
        let health = model.taskHealth
        let delivery = model.delivered?.delivered.max {
            AtlasTime.ms($0.recordedAt) < AtlasTime.ms($1.recordedAt)
        }
        let incident: AtlasNativeSnapshot.Fleet.Incident?
        if health?.incidents.present == true {
            incident = AtlasNativeSnapshot.Fleet.Incident(
                present: true,
                flags: health?.incidents.flags ?? [],
                recommendedAction: health?.operating.recommendedAction
            )
        } else {
            incident = nil
        }
        return AtlasNativeSnapshot.Fleet(
            scannedAt: health?.observedAt,
            incident: incident,
            lastDelivery: delivery.map {
                AtlasNativeSnapshot.Fleet.LastDelivery(
                    title: AtlasMarkdownJudgment.productCycleOutcome(index: $0.cycleIndex, outcome: $0.outcome),
                    mergeHash: $0.mergeHash,
                    at: $0.recordedAt
                )
            }
        )
    }

    static func iso(_ date: Date) -> String {
        date.formatted(.iso8601.year().month().day().time(includingFractionalSeconds: false).timeZone(separator: .omitted))
    }
}

extension AtlasNativeSnapshotWriter {
    static func liveSessions(from sessions: [LiveSessionSnapshot]) -> [AtlasNativeSnapshot.LiveSession]? {
        let projected = sessions.map { session in
            AtlasNativeSnapshot.LiveSession(
                title: session.title,
                phaseTitle: session.phaseTitle,
                timing: timing(from: session.timing),
                elapsedActiveMs: session.elapsedActiveMs,
                runningSince: session.runningSince.map(iso)
            )
        }
        return projected.isEmpty ? [] : projected
    }

    static func timing(from timing: AtlasExecutionPresence.Timing) -> AtlasNativeSnapshot.LiveSession.Timing {
        switch timing {
        case .running: return .running
        case .paused: return .paused
        case .finished: return .finished
        }
    }
}

@MainActor
final class AtlasNativeSnapshotWriter {
    static let shared = AtlasNativeSnapshotWriter()

    private var latestFleet: AtlasNativeSnapshot.Fleet?
    private var latestWeek: AtlasNativeSnapshot.Week?
    private var latestQueuedCount: Int?
    private var latestRemoteLiveSessions: [LiveSessionSnapshot] = []
    private let store: AtlasNativeSnapshotStore?

    private init() {
        if let file = AtlasNativeSnapshotStore.appGroupFileURL() {
            store = AtlasNativeSnapshotStore(fileURL: file)
        } else {
            store = nil
        }
    }

    func recordAutonomos(_ model: AutonomosModel) {
        latestFleet = Self.fleet(from: model)
        Task { await write() }
    }

    func recordCodeWeek(_ week: AtlasCodeWeek?) {
        latestWeek = week.map {
            AtlasNativeSnapshot.Week(
                window: $0.window,
                commits: $0.commits,
                heals: $0.heals,
                prevented: $0.prevented
            )
        }
        Task { await write() }
    }

    func recordQueuedCount(_ count: Int) {
        latestQueuedCount = max(0, count)
        Task { await write() }
    }

    func recordRemoteLiveSessions(_ sessions: [LiveSessionSnapshot]) {
        latestRemoteLiveSessions = sessions
        Task { await write() }
    }

    func write() async {
        guard let store else { return }
        let snapshot = AtlasNativeSnapshot(
            generatedAt: Date(),
            liveSessions: Self.liveSessions(from: TurnPresence.shared.liveSessions + latestRemoteLiveSessions),
            fleet: latestFleet,
            week: latestWeek,
            queuedCount: latestQueuedCount
        )
        try? await store.save(snapshot)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
