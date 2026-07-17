import SwiftUI
import AtlasCore

// Code block "carved in slate" com label de linguagem + botão copiar (gap do RN).
// Scroll horizontal pra linhas longas; JetBrains Mono; copia SÓ este bloco.
// Peel de AtlasMarkdownView (régua anti-inchaço).
struct CodeBlockView: View {
    let code: String
    let lang: String?
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text((lang?.isEmpty == false ? lang! : "código").lowercased())
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                Spacer()
                Button {
                    UIPasteboard.general.string = code
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(AtlasMotion.editorial) { copied = true }
                    Task { try? await Task.sleep(nanoseconds: 1_200_000_000); withAnimation(AtlasMotion.editorial) { copied = false } }
                } label: {
                    Text(copied ? "copiado" : "copiar")
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(copied ? AtlasTheme.accent : AtlasTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(AtlasFont.mono(13)).foregroundStyle(AtlasTheme.textPrimary)
                    .lineSpacing(5).textSelection(.enabled)
                    .padding(.horizontal, 16).padding(.bottom, 14)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10).fill(AtlasTheme.surface)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AtlasTheme.separator, lineWidth: 1))
        )
    }
}
