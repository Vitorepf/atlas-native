import AtlasCore
import SwiftUI

/// Linha de repositório do radar — label visual + spoken honesty.
struct AtlasCodeRepoRow: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let repo: AtlasCodeRepoRef
    let issues: [AtlasCodeIssue]?
    /// Trunk real: a frase da issue fala o nome da linha.
    var trunk: String? = nil
    /// Nos recentes a pasta situa; dentro da pasta seria redundante.
    let showsFolder: Bool
    let onTap: () -> Void

    var body: some View {
        // children:.ignore: nó único com label/id — necessário p/ walk a11y estável.
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onTap()
        } label: {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 7) {
                        Text(repo.name)
                            .atlasSans(15, .medium)
                            .foregroundStyle(AtlasTheme.textPrimary)
                        if showsFolder, let folder = repo.folder {
                            Text(folder)
                                .atlasSans(10)
                                .foregroundStyle(AtlasTheme.textTertiary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1.5)
                                .background(Capsule().fill(AtlasTheme.surface))
                        }
                    }
                    if let issues, let first = issues.first {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(first.isSevere
                                      ? AtlasCodePalette.alert
                                      : AtlasCodePalette.alert.opacity(0.45))
                                .frame(width: 4.5, height: 4.5)
                            Text(
                                issues.count == 1
                                    ? first.headline(trunk: trunk)
                                    : "\(first.headline(trunk: trunk)) · mais \(issues.count - 1) alerta\(issues.count - 1 == 1 ? "" : "s")"
                            )
                            .atlasSans(12)
                            .foregroundStyle(AtlasTheme.textSecondary)
                            .lineLimit(1)
                        }
                    }
                }
                .accessibilityHidden(true)
                Spacer(minLength: 6)
                if let age = AtlasCodeAge.short(from: repo.lastCommitAt) {
                    Text(age)
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .monospacedDigit()
                        .accessibilityHidden(true)
                }
                Image(systemName: "chevron.right")
                    .atlasSans(12, .semibold)
                    .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 13)
            .frame(minHeight: 48, alignment: .center)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel)
        .accessibilityHint("abre o grafo do repositório")
        .accessibilityIdentifier(A11yID.radarRepo(repo.slug))
    }

    /// Desvios só com `issues` publicados; nil = silêncio, nunca fabrica limpo.
    private var spokenLabel: String {
        var parts = [repo.name]
        if showsFolder, let folder = repo.folder, !folder.isEmpty {
            parts.append("pasta \(folder)")
        }
        if let issues, !issues.isEmpty {
            if let first = issues.first {
                parts.append(first.headline(trunk: trunk))
                if first.isSevere { parts.append("alta severidade") }
            }
            if issues.count > 1 {
                let more = issues.count - 1
                parts.append("mais \(more) sem retorno\(more == 1 ? "" : "s")")
            }
        }
        if let age = AtlasCodeAge.short(from: repo.lastCommitAt) {
            parts.append("último commit \(age)")
        }
        return parts.joined(separator: ", ")
    }
}
