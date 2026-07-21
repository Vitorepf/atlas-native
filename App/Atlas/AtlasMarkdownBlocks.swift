import SwiftUI
import AtlasCore

// WAVE-017 markdown

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

