import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: Atlas Code presentation helpers fused

// MARK: - AtlasCodePalette

extension AtlasCodePalette {
    static func colorHealthy(for state: AtlasCodeNodeState) -> Color? {
        switch state {
        case .onMain: return onMain
        case .healed: return healed
        default: return nil
        }
    }
}

extension AtlasCodePalette {
    static func color(for state: AtlasCodeNodeState) -> Color {
        if let healthy = colorHealthy(for: state) { return healthy }
        switch state {
        case .violating: return alert
        case .history: return history
        default: return history
        }
    }
}

enum AtlasCodePalette {
    static let onMain = AtlasTheme.accent
    static let alert = Color(hex: 0xE08C8C)
    static let healed = Color(hex: 0x83B46D)
    static let history = Color(hex: 0x647682)
}
// MARK: - AtlasCodeRelativeTime

enum AtlasCodeRelativeTime {
    static func short(from epoch: Int, now: Date = Date()) -> String {
        let seconds = max(0, Int(now.timeIntervalSince1970) - epoch)
        switch seconds {
        case ..<3600: return "\(max(1, seconds / 60))min"
        case ..<86_400: return "\(seconds / 3600)h"
        case ..<2_592_000: return "\(seconds / 86_400)d"
        default: return "\(seconds / 2_592_000)mês"
        }
    }
}
// MARK: - AtlasCodeWeekUI

enum AtlasCodeWeekUI {
    static func isQuiet(commits: Int, heals: Int, prevented: Int) -> Bool {
        commits == 0 && heals == 0 && prevented == 0
    }

    static func isQuiet(_ week: AtlasCodeWeek) -> Bool {
        isQuiet(commits: week.commits, heals: week.heals, prevented: week.prevented)
    }

    static func weekPhaseID(_ week: AtlasCodeWeek) -> String {
        if isQuiet(week) { return "quiet-\(week.window)" }
        return "active-\(week.window)-\(week.commits)-\(week.heals)-\(week.prevented)"
    }

    static func spokenLabel(window: String, commits: Int, heals: Int, prevented: Int) -> String {
        if isQuiet(commits: commits, heals: heals, prevented: prevented) {
            return "A semana \(window), semana quieta, sem commits nem curas"
        }
        var parts = ["A semana \(window)"]
        if commits > 0 { parts.append("\(commits) commit\(commits == 1 ? "" : "s")") }
        if heals > 0 { parts.append("\(heals) cura\(heals == 1 ? "" : "s")") }
        if prevented > 0 { parts.append("\(prevented) prevenida\(prevented == 1 ? "" : "s")") }
        return parts.joined(separator: ", ")
    }

    static func spokenLabel(_ week: AtlasCodeWeek) -> String {
        spokenLabel(
            window: week.window,
            commits: week.commits,
            heals: week.heals,
            prevented: week.prevented
        )
    }
}
// MARK: - AtlasCodeChipRow

struct AtlasCodeChipRow: View {
    let items: [String]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasCodePalette.healed)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .overlay(
                        Capsule().strokeBorder(AtlasCodePalette.healed.opacity(0.3), lineWidth: 1)
                    )
            }
        }
    }
}
// MARK: - AtlasCodeLoadFailure

struct AtlasCodeLoadFailureEmpty: View {
    let headline: String
    let message: String
    let onRetry: () -> Void

    var body: some View {
        AtlasOpsFailureEmpty(
            mode: .load(headline: headline, message: message),
            layout: .centered,
            symbol: "exclamationmark.triangle",
            topPadding: 0,
            accessibilityIdentifier: A11yID.codeLoadFailure,
            retryAccessibilityIdentifier: A11yID.codeLoadRetry,
            retryHint: "recarrega o grafo ou radar deste repositório",
            spokenOverride: "\(headline). \(message)",
            onRetry: onRetry
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
// MARK: - AtlasCodeWorkspaceCache

@MainActor
enum AtlasCodeWorkspaceCache {
    private static var structure: AtlasCodeWorkspaceResponse?
    private static var fetchedAt: Date?
    /// 90s: troca de repo no mesmo minuto não paga getCodeWorkspace de novo.
    private static let ttl: TimeInterval = 90

    static func peek() -> AtlasCodeWorkspaceResponse? {
        guard let structure, let fetchedAt,
              Date().timeIntervalSince(fetchedAt) < ttl else { return nil }
        return structure
    }

    static func store(_ response: AtlasCodeWorkspaceResponse) {
        structure = response
        fetchedAt = Date()
    }

    static func invalidate() {
        structure = nil
        fetchedAt = nil
    }
}
// MARK: - AtlasCodeMirrorModel

@MainActor
@Observable
final class AtlasCodeMirrorModel {
    private let client: AtlasClient
    private(set) var repo: String
    private(set) var response: AtlasCodeMirrorResponse?

    init(client: AtlasClient, repo: String) {
        self.client = client
        self.repo = repo
    }

    func adoptRepo(_ newRepo: String) {
        guard newRepo != repo else { return }
        repo = newRepo
        response = nil
    }

    func refresh() async {
        // Sem resposta, a seção não fala — ausência nunca vira "0 a espelhar".
        //
        // E falha NÃO APAGA a leitura anterior: `response = try?` zerava o
        // card no primeiro fetch que caísse, e o estado que mais precisa de
        // olho — espelho BLOQUEADO POR SEGREDO — sumia da tela por causa de
        // uma queda de rede. O alarme aceso fica aceso até uma leitura REAL
        // dizer o contrário; só resposta nova escreve o estado.
        if let fresh = try? await client.getCodeMirror(repo: repo) {
            response = fresh
        }
    }
}

// MARK: - Repo picker sheet

struct AtlasCodeRepoPickerSheet: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var model: AtlasCodeWorkspaceModel
    let currentRepo: String
    let onPick: (String) -> Void

    init(client: AtlasClient, currentRepo: String, onPick: @escaping (String) -> Void) {
        let catalog = AtlasCodeWorkspaceModel(client: client)
        catalog.seedFromCache()
        _model = State(initialValue: catalog)
        self.currentRepo = currentRepo
        self.onPick = onPick
    }

    var body: some View {
        NavigationStack {
            Group {
                switch model.phase {
                case .loaded:
                    if let workspace = model.workspace, workspace.repositoryCount > 0 {
                        repoScroll(workspace)
                    } else {
                        ContentUnavailableView(
                            WorkspacePickerJudgment.noRepoLabel,
                            systemImage: "folder",
                            description: Text("o workspace não publicou nenhum repo")
                        )
                    }
                case .failed:
                    ContentUnavailableView(
                        "não consegui ler a frota",
                        systemImage: "wifi.slash",
                        description: Text("tente de novo em instantes")
                    )
                default:
                    VStack(spacing: 12) {
                        BreathingDiamond(size: 10, reduceMotion: reduceMotion)
                        Text(WorkspacePickerJudgment.loadingCopy)
                            .font(AtlasFont.serifItalic(15))
                            .foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityLabel(WorkspacePickerJudgment.spokenLoading())
                }
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Repositório")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                Text("Repositório")
                    .font(AtlasFont.serif(18))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                    .accessibilityAddTraits(.isHeader)
            }
            .task {
                // Cache hit → phase já .loaded; miss → uma ida à rede.
                if model.phase == .idle { await model.loadStructure() }
            }
            .accessibilityIdentifier(A11yID.codeRepoPicker)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(AtlasTheme.bg)
    }

    private func repoScroll(_ workspace: AtlasCodeWorkspaceResponse) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if !workspace.recents.isEmpty {
                    section("recentes", repos: workspace.recents)
                }
                ForEach(workspace.folders) { folder in
                    section(folder.name, repos: folder.repos)
                }
                if !workspace.loose.isEmpty {
                    section("avulsos", repos: workspace.loose)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 12)
            .padding(.bottom, 28)
        }
    }

    private func section(_ title: String, repos: [AtlasCodeRepoRef]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(AtlasFont.mono(11, .medium))
                .tracking(1.6)
                .foregroundStyle(AtlasTheme.textTertiary)
            VStack(spacing: 0) {
                ForEach(Array(repos.enumerated()), id: \.element.id) { index, repo in
                    repoRow(repo)
                    if index < repos.count - 1 {
                        Divider().overlay(AtlasTheme.separatorSoft)
                    }
                }
            }
            .atlasCard()
        }
    }

    private func repoRow(_ repo: AtlasCodeRepoRef) -> some View {
        Button {
            onPick(repo.slug)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "folder")
                    .font(.system(size: 15))
                    .foregroundStyle(AtlasTheme.textTertiary)
                Text(repo.name)
                    .atlasSans(15, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(1)
                Spacer(minLength: 0)
                if repo.slug == currentRepo {
                    Circle()
                        .fill(AtlasTheme.accent)
                        .frame(width: 6, height: 6)
                        .accessibilityLabel(WorkspacePickerJudgment.currentRepoBadgeLabel)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(WorkspacePickerJudgment.spokenRow(repo))
        .accessibilityHint(repo.slug == currentRepo ? "repositório atual" : "abre o grafo deste repositório")
        .accessibilityIdentifier(A11yID.codeRepoPickerRow(repo.slug))
    }
}
