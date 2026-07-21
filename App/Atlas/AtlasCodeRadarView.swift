import AtlasCore
import SwiftUI

/// M3 · Código — o workspace do operador como ele realmente é.
/// Seções / linhas → AtlasCodeRadarSections / AtlasCodeRadarRows / FolderRow.
struct AtlasCodeRadarView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var model: AtlasCodeWorkspaceModel
    let onOpenRepo: (String) -> Void

    init(client: AtlasClient, onOpenRepo: @escaping (String) -> Void) {
        _model = State(initialValue: AtlasCodeWorkspaceModel(client: client))
        self.onOpenRepo = onOpenRepo
    }

    private var contentPhaseID: String {
        switch model.phase {
        case .idle: return "idle"
        case .loading: return "loading"
        case .failed: return "failed"
        case .loaded:
            guard let workspace = model.workspace else { return "loaded-nil" }
            if workspace.repositoryCount == 0 { return "loaded-empty" }
            return "loaded-\(workspace.repositoryCount)"
        }
    }

    private static let shellHint = "pastas, recentes e sem retorno verificados do seu código"

    var body: some View {
        radarContent
            .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
            .navigationTitle("Código")
            .navigationBarTitleDisplayMode(.inline)
            .task { if model.phase == .idle { await model.load() } }
            .refreshable { await model.load() }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .accessibilityIdentifier(A11yID.radarScreen)
            // Contain without fused label: folder/repo rows stay focusable.
            .accessibilityElement(children: .contain)
            .accessibilityHint(Self.shellHint)
    }

    @ViewBuilder
    private var radarContent: some View {
        switch model.phase {
        case .idle, .loading:
            TraceEvidenceLoading(text: "lendo o seu workspace…", reduceMotion: reduceMotion)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier(A11yID.radarLoading)
        case .failed(let message):
            AtlasCodeLoadFailureEmpty(
                headline: "não consegui ler o workspace",
                message: message.trimmingCharacters(in: .whitespacesAndNewlines),
                onRetry: { Task { await model.load() } }
            )
            .accessibilityLabel(spokenFailed(message))
            .accessibilityHint("reconecta ao servidor Atlas")
            .accessibilityIdentifier(A11yID.radarFailure)
        case .loaded:
            if let workspace = model.workspace {
                AtlasCodeRadarLoadedContent(
                    workspace: workspace,
                    model: model,
                    onOpenRepo: onOpenRepo
                )
            } else {
                AtlasEditorialGlyphEmpty(
                    headline: "“Workspace sem repositórios legíveis.”",
                    footnote: "o Mac respondeu, mas nenhuma pasta de produto veio nesta leitura",
                    accessibilityIdentifier: A11yID.radarEmpty,
                    spokenLabel: spokenEmptyWorkspace()
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - Spoken (phase-local; shell uses contain-without-fuse)

    private func spokenEmptyWorkspace() -> String {
        "nenhum repositório neste workspace"
    }

    private func spokenFailed(_ message: String) -> String {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "workspace indisponível" }
        return "workspace indisponível, \(trimmed)"
    }
}


// Cycle 043 fuse → AtlasCodeLoadFailure.swift

/// Falha de carregamento Código — canônico (radar + grafo).
struct AtlasCodeLoadFailureEmpty: View {
    let headline: String
    let message: String
    let onRetry: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .atlasSans(24)
                .foregroundStyle(AtlasCodePalette.alert)
                .accessibilityHidden(true)
            Text(headline)
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(message)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onRetry()
            } label: {
                Text("Tentar de novo")
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.accent)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .frame(minHeight: 48)
                    .background(
                        Capsule().fill(AtlasTheme.goldVeil)
                            .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1))
                    )
                    .contentShape(Capsule())
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("tentar de novo")
            .accessibilityHint("recarrega o grafo ou radar deste repositório")
            .accessibilityIdentifier(A11yID.codeLoadRetry)
            .accessibilityAddTraits(.isButton)
            .accessibilitySortPriority(8)
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: 420, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.codeLoadFailure)
    }
}


/// Conteúdo carregado do radar — status, recentes, pastas, avulsos.
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
                    AtlasCodeRadarSectionLabel(text: "RECENTES", accessibilityID: A11yID.radarRecents)
                    ForEach(workspace.recents) { repo in
                        AtlasCodeRepoRow(
                            repo: repo,
                            issues: model.issues(for: repo.slug),
                            trunk: model.trunk(for: repo.slug),
                            showsFolder: true
                        ) {
                            onOpenRepo(repo.slug)
                        }
                        if repo.id != workspace.recents.last?.id { AtlasCodeRadarRowDivider() }
                    }
                }

                if !workspace.folders.isEmpty {
                    AtlasCodeRadarSectionLabel(text: "PASTAS", accessibilityID: A11yID.radarFolders)
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
                    AtlasCodeRadarSectionLabel(text: "AVULSOS", accessibilityID: A11yID.radarLoose)
                        .padding(.top, 22)
                    ForEach(workspace.loose) { repo in
                        AtlasCodeRepoRow(
                            repo: repo,
                            issues: model.issues(for: repo.slug),
                            trunk: model.trunk(for: repo.slug),
                            showsFolder: false
                        ) {
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


// MARK: - Status capsule + labels do radar

/// Silêncio = produto: clean → caption quieta; alarme só com violação real.
struct AtlasCodeRadarStatusCapsule: View {
    let model: AtlasCodeWorkspaceModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Group {
            switch model.scanState {
            case .clean, .unknown:
                Text(model.scanState == .clean ? "código" : model.headline)
                    .atlasSans(11, .semibold)
                    .tracking(1.2)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.vertical, 7)
                    .accessibilityHidden(true)
            case .violating:
                HStack(spacing: 7) {
                    Image(systemName: "exclamationmark.triangle")
                        .atlasSans(10, .semibold)
                        .accessibilityHidden(true)
                    Text(model.headline)
                        .atlasSans(11, .semibold)
                        .monospacedDigit()
                        .accessibilityHidden(true)
                }
                .foregroundStyle(AtlasCodePalette.alert)
                .padding(.horizontal, 15)
                .padding(.vertical, 7)
                .background(Capsule().fill(AtlasCodePalette.alert.opacity(0.09)))
                .overlay(Capsule().strokeBorder(AtlasCodePalette.alert.opacity(0.35), lineWidth: 1))
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: model.scanState)
        .frame(maxWidth: .infinity, minHeight: 36, alignment: .center)
        .accessibilityLabel(spokenStatus)
        .accessibilityAddTraits(model.scanState == .violating ? .isHeader : [])
        .accessibilityIdentifier(A11yID.radarStatus)
    }

    /// Frota quieta = caption mínima; alarme só com violação verificada no scan.
    private var spokenStatus: String {
        switch model.scanState {
        case .clean:
            return "código quieto, nada pede você"
        case .unknown:
            return model.headline
        case .violating:
            return "atenção, \(model.headline)"
        }
    }
}

struct AtlasCodeRadarSectionLabel: View {
    let text: String
    var accessibilityID: String? = nil

    var body: some View {
        Text(text)
            .atlasSans(10, .semibold)
            .tracking(1.3)
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier(accessibilityID ?? text)
    }
}

struct AtlasCodeRadarRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(AtlasTheme.separator.opacity(0.5))
            .frame(height: 0.5)
    }
}


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
        .accessibilityAddTraits(.isButton)
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


/// Linha de pasta do radar — expand/collapse + repos + spoken honesty.
struct AtlasCodeFolderRow: View {
    let folder: AtlasCodeFolder
    let isExpanded: Bool
    let issuesFor: (String) -> [AtlasCodeIssue]?
    let trunkFor: (String) -> String?
    let onToggle: () -> Void
    let onOpenRepo: (String) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    /// Só violações de repos já varridos — nil = ainda não medido, nunca conta limpo.
    private var verifiedExceptionCount: Int {
        folder.repos.reduce(0) { total, repo in
            guard let issues = issuesFor(repo.slug), !issues.isEmpty else { return total }
            return total + issues.reduce(0) { $0 + $1.count }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onToggle()
            } label: {
                HStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "folder")
                            .atlasSans(15)
                            .foregroundStyle(AtlasTheme.textSecondary)
                            .frame(width: 20)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(folder.name)
                                .atlasSans(15, .semibold)
                                .foregroundStyle(AtlasTheme.textPrimary)
                            Text(folder.repositories == 1
                                 ? "1 repositório"
                                 : "\(folder.repositories) repositórios")
                                .atlasSans(11.5)
                                .foregroundStyle(AtlasTheme.textTertiary)
                        }
                        .accessibilityHidden(true)
                    }
                    Spacer(minLength: 6)
                    if verifiedExceptionCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle")
                                .atlasSans(9, .semibold)
                            Text("\(verifiedExceptionCount)")
                                .atlasSans(11, .semibold)
                                .monospacedDigit()
                        }
                        .foregroundStyle(AtlasCodePalette.alert)
                        .accessibilityHidden(true)
                    }
                    Image(systemName: "chevron.right")
                        .atlasSans(12, .semibold)
                        .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .accessibilityHidden(true)
                }
                .padding(.vertical, 14)
                .frame(minHeight: 48, alignment: .center)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenFolderLabel)
            .accessibilityHint(isExpanded ? "recolhe a pasta" : "expande a pasta")
            .accessibilityAddTraits(isExpanded ? [.isButton, .isSelected] : .isButton)
            .accessibilityIdentifier(A11yID.radarFolder(folder.slug))

            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(folder.repos) { repo in
                        AtlasCodeRepoRow(
                            repo: repo,
                            issues: issuesFor(repo.slug),
                            trunk: trunkFor(repo.slug),
                            showsFolder: false
                        ) {
                            onOpenRepo(repo.slug)
                        }
                        .padding(.leading, 32)
                        if repo.id != folder.repos.last?.id {
                            Rectangle()
                                .fill(AtlasTheme.separator.opacity(0.4))
                                .frame(height: 0.5)
                                .padding(.leading, 32)
                                .accessibilityHidden(true)
                        }
                    }
                }
                .padding(.bottom, 6)
                .transition(reduceMotion ? .identity : .opacity)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: isExpanded)
    }

    private var spokenFolderLabel: String {
        var parts = [
            folder.name,
            folder.repositories == 1 ? "1 repositório" : "\(folder.repositories) repositórios"
        ]
        if verifiedExceptionCount > 0 {
            let n = verifiedExceptionCount
            parts.append("\(n) sem retorno\(n == 1 ? "" : "s") verificado\(n == 1 ? "" : "s")")
        }
        if isExpanded { parts.append("expandida") }
        return parts.joined(separator: ", ")
    }
}
