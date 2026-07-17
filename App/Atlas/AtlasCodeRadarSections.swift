import AtlasCore
import SwiftUI

// MARK: - Seções do AtlasCodeRadarView
// Extraídas sem mudança de comportamento — a view só compõe.

struct AtlasCodeRadarStatusCapsule: View {
    let model: AtlasCodeWorkspaceModel

    private var tone: Color {
        switch model.scanState {
        case .violating: return AtlasCodePalette.alert
        case .clean: return AtlasCodePalette.healed
        case .unknown: return AtlasTheme.textTertiary
        }
    }

    private var simbolo: String {
        switch model.scanState {
        case .violating: return "exclamationmark.triangle"
        case .clean: return "checkmark"
        case .unknown: return "questionmark"
        }
    }

    var body: some View {
        // Três estados, como no grafo: verde é AFIRMAÇÃO sobre a frota e só sai
        // quando a conta fecha. "lendo o workspace…" com ✓ verde ao lado eram
        // dois estados contraditórios ao mesmo tempo, nenhum deles verdadeiro.
        HStack(spacing: 7) {
            Image(systemName: simbolo)
                .font(.system(size: 10, weight: .semibold))
            Text(model.headline)
                .font(.system(size: 11, weight: .semibold))
                .monospacedDigit()
        }
        .foregroundStyle(tone)
        .padding(.horizontal, 15)
        .padding(.vertical, 7)
        .background(Capsule().fill(tone.opacity(0.09)))
        .overlay(Capsule().strokeBorder(tone.opacity(0.35), lineWidth: 1))
        .frame(maxWidth: .infinity, alignment: .center)
        .accessibilityLabel(model.headline)
        .accessibilityIdentifier(A11yID.radarStatus)
    }
}

struct AtlasCodeRadarSectionLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .tracking(1.3)
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.bottom, 8)
    }
}

struct AtlasCodeRadarRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(AtlasTheme.separator.opacity(0.5))
            .frame(height: 0.5)
    }
}

struct AtlasCodeRadarLoadedContent: View {
    let workspace: AtlasCodeWorkspaceResponse
    let model: AtlasCodeWorkspaceModel
    let onOpenRepo: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AtlasCodeRadarStatusCapsule(model: model)
                    .padding(.bottom, 18)

                if !workspace.recents.isEmpty {
                    AtlasCodeRadarSectionLabel(text: "RECENTES")
                    ForEach(workspace.recents) { repo in
                        AtlasCodeRepoRow(repo: repo, issues: model.issues(for: repo.slug), trunk: model.trunk(for: repo.slug), showsFolder: true) {
                            onOpenRepo(repo.slug)
                        }
                        if repo.id != workspace.recents.last?.id { AtlasCodeRadarRowDivider() }
                    }
                }

                if !workspace.folders.isEmpty {
                    AtlasCodeRadarSectionLabel(text: "PASTAS")
                        .padding(.top, 22)
                    ForEach(workspace.folders) { folder in
                        AtlasCodeFolderRow(
                            folder: folder,
                            isExpanded: model.expandedFolders.contains(folder.slug),
                            issuesFor: { model.issues(for: $0) },
                            trunkFor: { model.trunk(for: $0) },
                            onToggle: { Task { await model.toggle(folder) } },
                            onOpenRepo: onOpenRepo
                        )
                        if folder.id != workspace.folders.last?.id { AtlasCodeRadarRowDivider() }
                    }
                }

                if !workspace.loose.isEmpty {
                    AtlasCodeRadarSectionLabel(text: "AVULSOS")
                        .padding(.top, 22)
                    ForEach(workspace.loose) { repo in
                        AtlasCodeRepoRow(repo: repo, issues: model.issues(for: repo.slug), trunk: model.trunk(for: repo.slug), showsFolder: false) {
                            onOpenRepo(repo.slug)
                        }
                        if repo.id != workspace.loose.last?.id { AtlasCodeRadarRowDivider() }
                    }
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
    }
}

// MARK: - Linha de repositório

struct AtlasCodeRepoRow: View {
    let repo: AtlasCodeRepoRef
    let issues: [AtlasCodeIssue]?
    /// A trunk real deste repo: a frase da issue fala o nome da linha.
    var trunk: String? = nil
    /// Nos recentes a pasta situa; dentro da pasta seria redundante.
    let showsFolder: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 7) {
                        Text(repo.name)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(AtlasTheme.textPrimary)
                        if showsFolder, let folder = repo.folder {
                            Text(folder)
                                .font(.system(size: 10))
                                .foregroundStyle(AtlasTheme.textTertiary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1.5)
                                .background(Capsule().fill(AtlasTheme.surface))
                        }
                    }
                    // A história do repo em português — só quando existe.
                    if let issues, let first = issues.first {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(first.isSevere ? AtlasCodePalette.alert : AtlasCodePalette.alert.opacity(0.45))
                                .frame(width: 4.5, height: 4.5)
                            Text(issues.count == 1 ? first.headline(trunk: trunk) : "\(first.headline(trunk: trunk)) · +\(issues.count - 1)")
                                .font(.system(size: 12))
                                .foregroundStyle(AtlasTheme.textSecondary)
                                .lineLimit(1)
                        }
                    }
                }
                Spacer(minLength: 6)
                if let age = AtlasCodeAge.short(from: repo.lastCommitAt) {
                    Text(age)
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .monospacedDigit()
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
            }
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
        .accessibilityIdentifier(A11yID.radarRepo(repo.slug))
    }

    private var accessibilityText: String {
        var parts = [repo.name]
        if let issues, !issues.isEmpty { parts.append(issues.map { $0.headline(trunk: trunk) }.joined(separator: ", ")) }
        if let age = AtlasCodeAge.short(from: repo.lastCommitAt) { parts.append("último commit \(age)") }
        return parts.joined(separator: ", ")
    }
}

// MARK: - Linha de pasta (produto)

struct AtlasCodeFolderRow: View {
    let folder: AtlasCodeFolder
    let isExpanded: Bool
    let issuesFor: (String) -> [AtlasCodeIssue]?
    let trunkFor: (String) -> String?
    let onToggle: () -> Void
    let onOpenRepo: (String) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var exceptionCount: Int {
        folder.repos.reduce(0) { $0 + (issuesFor($1.slug)?.reduce(0) { $0 + $1.count } ?? 0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack(spacing: 12) {
                    Image(systemName: "folder")
                        .font(.system(size: 15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .frame(width: 20)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(folder.name)
                            .font(AtlasFont.serif(16, .semibold))
                            .foregroundStyle(AtlasTheme.textPrimary)
                        Text(folder.repositories == 1 ? "1 repositório" : "\(folder.repositories) repositórios")
                            .font(.system(size: 11.5))
                            .foregroundStyle(AtlasTheme.textTertiary)
                    }
                    Spacer(minLength: 6)
                    if exceptionCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 9, weight: .semibold))
                            Text("\(exceptionCount)")
                                .font(.system(size: 11, weight: .semibold))
                                .monospacedDigit()
                        }
                        .foregroundStyle(AtlasCodePalette.alert)
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(folder.name), \(folder.repositories) repositórios\(exceptionCount > 0 ? ", \(exceptionCount) problemas" : "")")
            .accessibilityIdentifier(A11yID.radarFolder(folder.slug))

            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(folder.repos) { repo in
                        AtlasCodeRepoRow(repo: repo, issues: issuesFor(repo.slug), trunk: trunkFor(repo.slug), showsFolder: false) {
                            onOpenRepo(repo.slug)
                        }
                        .padding(.leading, 32)
                        if repo.id != folder.repos.last?.id {
                            Rectangle()
                                .fill(AtlasTheme.separator.opacity(0.4))
                                .frame(height: 0.5)
                                .padding(.leading, 32)
                        }
                    }
                }
                .padding(.bottom, 6)
                .transition(.opacity)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: isExpanded)
    }
}
