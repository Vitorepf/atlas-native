import SwiftUI
import AtlasCore

/// Uma linha por arquivo. O VERBO é a forma do símbolo, não a cor: cor aqui
/// é reservada ao estado do commit (main/fora/curado) e mentiria se pintasse
/// tipo de mudança de vermelho dentro de um commit saudável.
/// Meta → AtlasCodeFileRow+Meta.swift
struct AtlasCodeFileRow: View {
    let file: AtlasCodeFileChange
    var accessibilityIdentifier: String?

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 8.5, weight: .bold))
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 17, height: 17)
                .background(AtlasTheme.surfaceHi, in: RoundedRectangle(cornerRadius: 5))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 1) {
                Text(file.fileName)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                if let subtitle {
                    Text(subtitle)
                        .font(AtlasFont.mono(8.5))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(1)
                        .truncationMode(.head)
                }
            }
            .accessibilityHidden(true)

            Spacer(minLength: 8)

            if let additions = file.additions, let deletions = file.deletions {
                Text("+\(additions) \u{2212}\(deletions)")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .accessibilityHidden(true)
            } else {
                Text("binário")
                    .font(AtlasFont.mono(8.5))
                    .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, 9)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AtlasCodeFileRowA11y.spokenFile(file))
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}
