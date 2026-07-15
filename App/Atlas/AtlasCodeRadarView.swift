import AtlasCore
import Observation
import SwiftUI

/// M3 · Código — o workspace do operador como ele realmente é.
///
/// Modelo mental correto: `Atlas/` e `blackink/` são PASTAS de produto que
/// contêm repositórios; pasta não é repositório quebrado. A tela mostra
/// **Recentes** (o trabalho vivo — atalho, não cópia) e **Pastas** (a verdade
/// completa). A exceção de cada repo aparece em português e é resolvida sob
/// demanda: varrer 12 repos de uma vez para pintar a lista seria caro; aqui
/// a exceção chega quando chega, e enquanto não chega a linha não fala.
@MainActor
@Observable
final class AtlasCodeWorkspaceModel {
    enum Phase: Equatable {
        case idle, loading, loaded, failed(String)
    }

    private let client: AtlasClient
    private(set) var phase: Phase = .idle
    private(set) var workspace: AtlasCodeWorkspaceResponse?
    /// Exceções por repo (slug → issues). Chave ausente = ainda não varrido.
    private(set) var issuesBySlug: [String: [AtlasCodeIssue]] = [:]
    private(set) var expandedFolders: Set<String> = []

    init(client: AtlasClient) {
        self.client = client
    }

    func load() async {
        phase = .loading
        do {
            let response = try await client.getCodeWorkspace()
            workspace = response
            phase = .loaded
            // Os recentes são o que o operador olha primeiro: varre esses já.
            await scan(response.recents.map(\.slug))
        } catch {
            phase = .failed(String(describing: error))
        }
    }

    /// Varredura sob demanda: repo que não responde não ganha sinal — jamais
    /// vira "0 problemas".
    func scan(_ slugs: [String]) async {
        for slug in slugs where issuesBySlug[slug] == nil {
            guard let response = try? await client.getCodeViolations(repo: slug) else { continue }
            issuesBySlug[slug] = Self.group(response.violations)
        }
    }

    func toggle(_ folder: AtlasCodeFolder) async {
        if expandedFolders.contains(folder.slug) {
            expandedFolders.remove(folder.slug)
        } else {
            expandedFolders.insert(folder.slug)
            await scan(folder.repos.map(\.slug))
        }
    }

    func issues(for slug: String) -> [AtlasCodeIssue]? { issuesBySlug[slug] }

    /// A frase do workspace: o problema dominante entre o que já foi varrido.
    var headline: String {
        let all = issuesBySlug.values.flatMap { $0 }
        guard !all.isEmpty else {
            return issuesBySlug.isEmpty ? "lendo o workspace…" : "nada pede você"
        }
        var byRule: [String: AtlasCodeIssue] = [:]
        for issue in all {
            if let existing = byRule[issue.ruleId] {
                byRule[issue.ruleId] = AtlasCodeIssue(
                    ruleId: issue.ruleId,
                    count: existing.count + issue.count,
                    severity: existing.isSevere || issue.isSevere ? "high" : issue.severity,
                    oldestDays: [existing.oldestDays, issue.oldestDays].compactMap { $0 }.max()
                )
            } else {
                byRule[issue.ruleId] = issue
            }
        }
        let worst = byRule.values.sorted { ($0.isSevere ? 0 : 1, -$0.count) < ($1.isSevere ? 0 : 1, -$1.count) }
        return worst.first?.headline ?? "nada pede você"
    }

    var hasException: Bool { issuesBySlug.values.contains { !$0.isEmpty } }

    /// Agrupa violações cruas por regra medindo a idade real do caso mais
    /// antigo — mesmo contrato do servidor.
    private static func group(_ violations: [AtlasCodeViolation], now: Date = Date()) -> [AtlasCodeIssue] {
        var byRule: [String: (count: Int, severe: Bool, oldest: Int?)] = [:]
        for violation in violations {
            var entry = byRule[violation.ruleId] ?? (0, false, nil)
            entry.count += 1
            entry.severe = entry.severe || violation.severity == "high"
            if let since = violation.since, let date = AtlasCodeISO.date(from: since) {
                let days = max(0, Int(now.timeIntervalSince(date) / 86_400))
                entry.oldest = max(entry.oldest ?? 0, days)
            }
            byRule[violation.ruleId] = entry
        }
        return byRule
            .map { AtlasCodeIssue(ruleId: $0.key, count: $0.value.count, severity: $0.value.severe ? "high" : "medium", oldestDays: $0.value.oldest) }
            .sorted { ($0.isSevere ? 0 : 1, -$0.count) < ($1.isSevere ? 0 : 1, -$1.count) }
    }
}

enum AtlasCodeISO {
    /// Swift 6: ISO8601DateFormatter não é Sendable. Instanciar por chamada é
    /// barato aqui (dezenas de datas, não milhares) e elimina o data race —
    /// correção real, não `nonisolated(unsafe)` varrendo o problema pra baixo
    /// do tapete.
    static func date(from text: String) -> Date? {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = fractional.date(from: text) { return date }
        return ISO8601DateFormatter().date(from: text)
    }
}

struct AtlasCodeRadarView: View {
    @Environment(AtlasSession.self) private var session
    @State private var model: AtlasCodeWorkspaceModel
    let onOpenRepo: (String) -> Void

    init(client: AtlasClient, onOpenRepo: @escaping (String) -> Void) {
        _model = State(initialValue: AtlasCodeWorkspaceModel(client: client))
        self.onOpenRepo = onOpenRepo
    }

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            content
        }
        .navigationTitle("Código")
        .navigationBarTitleDisplayMode(.inline)
        .task { if model.phase == .idle { await model.load() } }
        .refreshable { await model.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch model.phase {
        case .idle, .loading:
            VStack(spacing: 12) {
                ProgressView().tint(AtlasTheme.accent)
                Text("lendo o seu workspace…")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 22))
                    .foregroundStyle(AtlasCodePalette.alert)
                Text("não consegui ler o workspace")
                    .font(AtlasFont.serif(19, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text(message)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                Button("Tentar de novo") { Task { await model.load() } }
                    .buttonStyle(.borderedProminent)
                    .tint(AtlasTheme.accent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded:
            if let workspace = model.workspace {
                loaded(workspace)
            } else {
                Text("workspace vazio")
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func loaded(_ workspace: AtlasCodeWorkspaceResponse) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                statusCapsule
                    .padding(.bottom, 18)

                if !workspace.recents.isEmpty {
                    sectionLabel("RECENTES")
                    ForEach(workspace.recents) { repo in
                        AtlasCodeRepoRow(repo: repo, issues: model.issues(for: repo.slug), showsFolder: true) {
                            onOpenRepo(repo.slug)
                        }
                        if repo.id != workspace.recents.last?.id { rowDivider }
                    }
                }

                if !workspace.folders.isEmpty {
                    sectionLabel("PASTAS")
                        .padding(.top, 22)
                    ForEach(workspace.folders) { folder in
                        AtlasCodeFolderRow(
                            folder: folder,
                            isExpanded: model.expandedFolders.contains(folder.slug),
                            issuesFor: { model.issues(for: $0) },
                            onToggle: { Task { await model.toggle(folder) } },
                            onOpenRepo: onOpenRepo
                        )
                        if folder.id != workspace.folders.last?.id { rowDivider }
                    }
                }

                if !workspace.loose.isEmpty {
                    sectionLabel("AVULSOS")
                        .padding(.top, 22)
                    ForEach(workspace.loose) { repo in
                        AtlasCodeRepoRow(repo: repo, issues: model.issues(for: repo.slug), showsFolder: false) {
                            onOpenRepo(repo.slug)
                        }
                        if repo.id != workspace.loose.last?.id { rowDivider }
                    }
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .tracking(1.3)
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.bottom, 8)
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(AtlasTheme.separator.opacity(0.5))
            .frame(height: 0.5)
    }

    private var statusCapsule: some View {
        let tone: Color = model.hasException ? AtlasCodePalette.alert : AtlasCodePalette.healed
        return HStack(spacing: 7) {
            Image(systemName: model.hasException ? "exclamationmark.triangle" : "checkmark")
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
        .accessibilityIdentifier("radar-status")
    }
}

// MARK: - Linha de repositório

private struct AtlasCodeRepoRow: View {
    let repo: AtlasCodeRepoRef
    let issues: [AtlasCodeIssue]?
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
                            Text(issues.count == 1 ? first.headline : "\(first.headline) · +\(issues.count - 1)")
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
        .accessibilityIdentifier("radar-repo-\(repo.slug)")
    }

    private var accessibilityText: String {
        var parts = [repo.name]
        if let issues, !issues.isEmpty { parts.append(issues.map(\.headline).joined(separator: ", ")) }
        if let age = AtlasCodeAge.short(from: repo.lastCommitAt) { parts.append("último commit \(age)") }
        return parts.joined(separator: ", ")
    }
}

// MARK: - Linha de pasta (produto)

private struct AtlasCodeFolderRow: View {
    let folder: AtlasCodeFolder
    let isExpanded: Bool
    let issuesFor: (String) -> [AtlasCodeIssue]?
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
            .accessibilityIdentifier("radar-folder-\(folder.slug)")

            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(folder.repos) { repo in
                        AtlasCodeRepoRow(repo: repo, issues: issuesFor(repo.slug), showsFolder: false) {
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
