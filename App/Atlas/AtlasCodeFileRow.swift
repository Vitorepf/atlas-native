import SwiftUI
import AtlasCore

/// Uma linha por arquivo. O VERBO é a forma do símbolo, não a cor: cor aqui
/// é reservada ao estado do commit (main/fora/curado) e mentiria se pintasse
/// tipo de mudança de vermelho dentro de um commit saudável.
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

            Spacer(minLength: 8)

            if let additions = file.additions, let deletions = file.deletions {
                Text("+\(additions) \u{2212}\(deletions)")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
            } else {
                Text("binário")
                    .font(AtlasFont.mono(8.5))
                    .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
            }
        }
        .padding(.vertical, 9)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }

    private var subtitle: String? {
        if let from = file.renamedFrom { return "de \(from)" }
        return file.directory
    }

    private var symbol: String {
        switch file.status {
        case .added: return "plus"
        case .modified: return "pencil"
        case .deleted: return "minus"
        case .renamed: return "arrow.right"
        case .copied: return "doc.on.doc"
        case .typeChanged: return "arrow.triangle.2.circlepath"
        case .unknown: return "questionmark"
        }
    }

    private var verb: String {
        switch file.status {
        case .added: return "adicionado"
        case .modified: return "alterado"
        case .deleted: return "removido"
        case .renamed: return "renomeado"
        case .copied: return "copiado"
        case .typeChanged: return "tipo alterado"
        case .unknown: return "mudança desconhecida"
        }
    }

    private var accessibilityText: String {
        var text = "\(file.path), \(verb)"
        if let from = file.renamedFrom { text += ", de \(from)" }
        if let additions = file.additions, let deletions = file.deletions {
            text += ", \(additions) linhas adicionadas, \(deletions) removidas"
        } else {
            text += ", arquivo binário"
        }
        return text
    }
}
