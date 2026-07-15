import AtlasCore
import Observation
import SwiftUI

/// M3 · Radar — a frota num olhar, por exceção.
///
/// Contrato visual: `docs/proposals/atlas-code-mobile.html` (tela M3).
/// Saudável = só o nome. A exceção fala com o NOME DA REGRA (um sinal
/// primário). Repo ilegível e scanner mudo são estados próprios — nenhum
/// deles é saúde, e nenhum vira "0".
@MainActor
@Observable
final class AtlasCodeRadarModel {
    enum Phase: Equatable {
        case idle, loading, loaded, failed(String)
    }

    private let client: AtlasClient
    private(set) var phase: Phase = .idle
    private(set) var repos: [AtlasCodeRepo] = []

    init(client: AtlasClient) {
        self.client = client
    }

    func load() async {
        phase = .loading
        do {
            // A exceção sobe: o que pede você vem antes do que está quieto;
            // o que nem foi lido fica por último.
            repos = try await client.getCodeRepos().repos.sorted { Self.rank($0.signal) < Self.rank($1.signal) }
            phase = .loaded
        } catch {
            phase = .failed(String(describing: error))
        }
    }

    private static func rank(_ signal: AtlasCodeRepo.Signal) -> Int {
        switch signal {
        case .exception: return 0
        case .silent: return 1
        case .scanUnavailable: return 2
        case .unreadable: return 3
        }
    }

    /// Quantos repositórios têm exceção agora — a única contagem que informa.
    var repositoriesWithException: Int {
        repos.filter { if case .exception = $0.signal { return true } else { return false } }.count
    }

    /// Quantos o Atlas conseguiu de fato julgar. Repo ilegível e scanner mudo
    /// NÃO entram: dizer "frota íntegra" sem ter lido nada seria mentira.
    var repositoriesJudged: Int {
        repos.filter {
            switch $0.signal {
            case .silent, .exception: return true
            case .unreadable, .scanUnavailable: return false
            }
        }.count
    }
}

struct AtlasCodeRadarView: View {
    @Environment(AtlasSession.self) private var session
    @State private var model: AtlasCodeRadarModel
    let onOpenRepo: (String) -> Void

    init(client: AtlasClient, onOpenRepo: @escaping (String) -> Void) {
        _model = State(initialValue: AtlasCodeRadarModel(client: client))
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
                Text("varrendo a frota…")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 22))
                    .foregroundStyle(AtlasCodePalette.alert)
                Text("não consegui ler a frota")
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
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    statusCapsule
                        .padding(.bottom, 6)
                    ForEach(model.repos) { repo in
                        AtlasCodeRepoCard(repo: repo) { onOpenRepo(repo.slug) }
                    }
                }
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 10)
                .padding(.bottom, 28)
            }
        }
    }

    /// A cápsula nunca declara saúde que não foi verificada: sem nenhum repo
    /// julgado, ela diz o estado honesto — "frota não lida".
    private var statusCapsule: some View {
        let exceptions = model.repositoriesWithException
        let judged = model.repositoriesJudged
        let tone: Color = exceptions > 0 ? AtlasCodePalette.alert
            : (judged == 0 ? AtlasTheme.textTertiary : AtlasCodePalette.healed)
        let icon = exceptions > 0 ? "exclamationmark.triangle" : (judged == 0 ? "eye.slash" : "checkmark")
        let text: String = {
            if exceptions > 0 {
                return exceptions == 1 ? "1 repositório pede atenção" : "\(exceptions) repositórios pedem atenção"
            }
            if judged == 0 { return "frota não lida" }
            return judged == model.repos.count ? "frota íntegra" : "\(judged) de \(model.repos.count) lidos · sem exceção"
        }()
        return HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
            Text(text)
                .font(.system(size: 11, weight: .semibold))
                .monospacedDigit()
        }
        .foregroundStyle(tone)
        .padding(.horizontal, 15)
        .padding(.vertical, 7)
        .background(Capsule().fill(tone.opacity(0.09)))
        .overlay(Capsule().strokeBorder(tone.opacity(0.35), lineWidth: 1))
        .frame(maxWidth: .infinity, alignment: .center)
        .accessibilityLabel(text)
        .accessibilityIdentifier("radar-status")
    }
}

private struct AtlasCodeRepoCard: View {
    let repo: AtlasCodeRepo
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 9) {
                    Text(repo.name ?? repo.slug)
                        .font(AtlasFont.serif(16, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Spacer(minLength: 6)
                    signalBadge
                }
                if case .exception(_, let rules) = repo.signal, !rules.isEmpty {
                    // Um sinal primário: a regra, pelo nome do canon.
                    HStack(spacing: 5) {
                        ForEach(rules.prefix(3), id: \.self) { rule in
                            Text(rule)
                                .font(AtlasFont.mono(9))
                                .foregroundStyle(AtlasCodePalette.alert)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .overlay(Capsule().strokeBorder(AtlasCodePalette.alert.opacity(0.3), lineWidth: 1))
                        }
                    }
                }
                if case .unreadable(let reason) = repo.signal {
                    Text(honestReason(reason))
                        .font(.system(size: 11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
                if case .scanUnavailable = repo.signal {
                    Text("varredura indisponível — sem juízo sobre este repo")
                        .font(.system(size: 11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
            }
            .padding(13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background, in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityText)
        .accessibilityIdentifier("radar-repo-\(repo.slug)")
    }

    @ViewBuilder
    private var signalBadge: some View {
        switch repo.signal {
        case .silent:
            EmptyView()  // saudável não grita
        case .exception(let count, _):
            HStack(spacing: 5) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 9, weight: .semibold))
                Text("\(count)")
                    .font(.system(size: 11, weight: .semibold))
                    .monospacedDigit()
            }
            .foregroundStyle(AtlasCodePalette.alert)
        case .unreadable:
            Image(systemName: "eye.slash")
                .font(.system(size: 11))
                .foregroundStyle(AtlasTheme.textTertiary)
        case .scanUnavailable:
            Image(systemName: "questionmark.circle")
                .font(.system(size: 11))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }

    private var background: Color {
        if case .exception = repo.signal { return AtlasCodePalette.alert.opacity(0.05) }
        return AtlasTheme.surface.opacity(0.4)
    }

    private var borderColor: Color {
        if case .exception = repo.signal { return AtlasCodePalette.alert.opacity(0.35) }
        return AtlasTheme.separator
    }

    private func honestReason(_ reason: String) -> String {
        switch reason {
        case "repository_path_missing": return "sem caminho configurado"
        case "repository_path_unreadable": return "caminho ilegível no Mac"
        case "not_a_git_repository": return "não é um repositório git"
        default: return reason
        }
    }

    private var accessibilityText: String {
        let name = repo.name ?? repo.slug
        switch repo.signal {
        case .silent: return "\(name), sem exceções"
        case .exception(let count, let rules): return "\(name), \(count) exceções, regras \(rules.joined(separator: ", "))"
        case .unreadable: return "\(name), ilegível"
        case .scanUnavailable: return "\(name), varredura indisponível"
        }
    }
}
