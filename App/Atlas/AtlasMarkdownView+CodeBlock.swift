import SwiftUI
import AtlasCore

// Code block "carved in slate" com label de linguagem + botão copiar (gap do RN).
// Scroll horizontal pra linhas longas; JetBrains Mono; copia SÓ este bloco.
// Peel de AtlasMarkdownView (régua anti-inchaço).
struct CodeBlockView: View {
    let code: String
    let lang: String?
    var blockIndex: Int = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var copied = false

    private var lineCount: Int {
        guard !code.isEmpty else { return 0 }
        return code.split(separator: "\n", omittingEmptySubsequences: false).count
    }

    private var canCopy: Bool { !code.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                if let langLabel = MarkdownCodeBlockA11y.langLabel(lang: lang) {
                    Text(langLabel)
                        .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                }
                Spacer()
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
            .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(AtlasFont.mono(13)).foregroundStyle(AtlasTheme.textPrimary)
                    .lineSpacing(5).textSelection(.enabled)
                    .padding(.horizontal, 16).padding(.bottom, 14)
                    .accessibilityLabel(MarkdownCodeBlockA11y.spokenBlock(lang: lang, lineCount: lineCount))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10).fill(AtlasTheme.surface)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AtlasTheme.separator, lineWidth: 1))
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.markdownCodeBlock(blockIndex))
    }

    private var copyButtonTitle: String {
        guard canCopy else { return "copiar" }
        return copied ? "copiado" : "copiar"
    }

    private var copyForeground: Color {
        guard canCopy else { return AtlasTheme.textTertiary.opacity(0.5) }
        return copied ? AtlasTheme.accent : AtlasTheme.textSecondary
    }

    private func copyCode() {
        guard canCopy else { return }
        UIPasteboard.general.string = code
        guard UIPasteboard.general.string == code else { return }
        if !reduceMotion { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
        setCopied(true)
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            setCopied(false)
        }
    }

    private func setCopied(_ value: Bool) {
        if reduceMotion { copied = value }
        else { withAnimation(AtlasMotion.editorial) { copied = value } }
    }
}
