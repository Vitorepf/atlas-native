import SwiftUI
import AtlasCore

// Renderiza markdown na tipografia do Atlas — porte de EditorialMarkdown.tsx.
// Regra de ouro: *italic* é SEMPRE Fraunces italic (oralidade); **bold** é Sans
// semibold (peso editorial); `code` é JetBrains Mono em surface (registro).
// Tom "operational" (padrão das respostas): corpo em Sans; headings escalonados.
struct AtlasMarkdownView: View {
    let text: String
    private var blocks: [MarkdownBlock] { AtlasMarkdown.parse(text) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                blockView(block)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func blockView(_ block: MarkdownBlock) -> some View {
        switch block {
        case .paragraph(let spans):
            Text(inline(spans, base: .init(font: .system(size: 16), size: 16, color: AtlasTheme.textPrimary)))
                .lineSpacing(6)

        case .heading(let level, let spans):
            heading(level, spans)

        case .list(let ordered, let items):
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                    HStack(alignment: .top, spacing: 0) {
                        if ordered {
                            Text("\(idx + 1).")
                                .font(AtlasFont.mono(13)).foregroundStyle(AtlasTheme.textSecondary)
                                .frame(width: 26, alignment: .leading).padding(.top, 3)
                        } else {
                            Text("—")
                                .font(.system(size: 16)).foregroundStyle(AtlasTheme.accent)
                                .frame(width: 22, alignment: .leading)
                        }
                        Text(inline(item, base: .init(font: .system(size: 16), size: 16, color: AtlasTheme.textPrimary)))
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

        case .quote(let spans):
            HStack(alignment: .top, spacing: 14) {
                RoundedRectangle(cornerRadius: 1).fill(AtlasTheme.accent).frame(width: 2)
                Text(inline(spans, base: .init(font: AtlasFont.serifItalic(17), size: 17, color: AtlasTheme.textPrimary)))
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .fixedSize(horizontal: false, vertical: true)

        case .code(let codeText, _):
            Text(codeText)
                .font(AtlasFont.mono(13)).foregroundStyle(AtlasTheme.textPrimary)
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 14).padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(AtlasTheme.surface)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AtlasTheme.separator, lineWidth: 1))
                )
                .textSelection(.enabled)

        case .divider:
            Rectangle().fill(AtlasTheme.separator).frame(height: 1).padding(.vertical, 2)

        case .table(let headers, let rows):
            tableView(headers, rows)
        }
    }

    @ViewBuilder
    private func heading(_ level: Int, _ spans: [InlineSpan]) -> some View {
        switch level {
        case 1:
            Text(inline(spans, base: .init(font: AtlasFont.serif(22, .semibold), size: 22, color: AtlasTheme.textPrimary)))
                .padding(.top, 4)
        case 2:
            Text(plain(spans).uppercased())
                .font(.system(size: 11, weight: .medium)).tracking(1.1)
                .foregroundStyle(AtlasTheme.textSecondary)
                .padding(.top, 6).padding(.bottom, 2)
        default:
            Text(inline(spans, base: .init(font: .system(size: 14, weight: .semibold), size: 14, color: AtlasTheme.textPrimary)))
                .padding(.top, 2)
        }
    }

    private func tableView(_ headers: [[InlineSpan]], _ rows: [[[InlineSpan]]]) -> some View {
        let colCount = max(headers.count, rows.map { $0.count }.max() ?? 0)
        return VStack(spacing: 0) {
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

            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 0) {
                    ForEach(0..<colCount, id: \.self) { ci in
                        Text(inline(ci < row.count ? row[ci] : [], base: .init(font: .system(size: 14), size: 14, color: AtlasTheme.textPrimary)))
                            .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 8)
                    }
                }
                .padding(.vertical, 12)
                .overlay(alignment: .bottom) { Rectangle().fill(AtlasTheme.separatorSoft).frame(height: 1) }
            }
        }
        .overlay(alignment: .top) { Rectangle().fill(AtlasTheme.separator).frame(height: 1) }
    }

    // MARK: - Inline → AttributedString (flui e quebra linha, com bg no code)

    private struct InlineBase { let font: Font; let size: CGFloat; let color: Color }

    private func inline(_ spans: [InlineSpan], base: InlineBase) -> AttributedString {
        var out = AttributedString()
        for span in spans {
            var piece: AttributedString
            switch span {
            case .text(let t):
                piece = AttributedString(t); piece.font = base.font; piece.foregroundColor = base.color
            case .bold(let t):
                piece = AttributedString(t)
                piece.font = .system(size: base.size, weight: .semibold)
                piece.foregroundColor = AtlasTheme.textPrimary
            case .italic(let t):
                piece = AttributedString(t)
                piece.font = AtlasFont.serifItalic(base.size)
                piece.foregroundColor = base.color
            case .code(let t):
                piece = AttributedString(" \(t) ")
                piece.font = AtlasFont.mono(13)
                piece.foregroundColor = AtlasTheme.textPrimary
                piece.backgroundColor = AtlasTheme.surface
            case .link(let t, let url):
                piece = AttributedString(t)
                piece.font = .system(size: base.size, weight: .medium)
                piece.foregroundColor = AtlasTheme.prussian
                piece.underlineStyle = .single
                if let u = URL(string: url) { piece.link = u }
            }
            out.append(piece)
        }
        return out
    }

    private func plain(_ spans: [InlineSpan]) -> String {
        spans.map {
            switch $0 {
            case .text(let t), .bold(let t), .italic(let t), .code(let t): return t
            case .link(let t, _): return t
            }
        }.joined()
    }
}
