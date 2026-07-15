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

    /// O problema dominante da frota inteira — o que o operador precisa ouvir
    /// primeiro. Soma o mesmo tipo entre repos, prioriza o grave.
    var headlineIssue: AtlasCodeIssue? {
        var byRule: [String: AtlasCodeIssue] = [:]
        for repo in repos {
            guard case .exception(_, let issues) = repo.signal else { continue }
            for issue in issues {
                if let existing = byRule[issue.ruleId] {
                    byRule[issue.ruleId] = AtlasCodeIssue(
                        ruleId: issue.ruleId,
                        count: existing.count + issue.count,
                        severity: existing.isSevere || issue.isSevere ? "high" : issue.severity,
                        oldestDays: max(existing.oldestDays ?? -1, issue.oldestDays ?? -1) >= 0
                            ? max(existing.oldestDays ?? 0, issue.oldestDays ?? 0) : nil
                    )
                } else {
                    byRule[issue.ruleId] = issue
                }
            }
        }
        return byRule.values.sorted {
            ($0.isSevere ? 0 : 1, -$0.count) < ($1.isSevere ? 0 : 1, -$1.count)
        }.first
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
            // A cápsula fala do PROBLEMA, não de uma contagem sem sujeito.
            if let issue = model.headlineIssue { return issue.headline }
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
            VStack(alignment: .leading, spacing: 0) {
                // Linha 1 · o nome. Em repouso, é a única coisa que existe.
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(repo.name ?? repo.slug)
                        .font(AtlasFont.serif(17, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Spacer(minLength: 6)
                    trailingMark
                }

                // Linha 2+ · a HISTÓRIA em português. Nunca id de regra.
                if case .exception(_, let issues) = repo.signal, !issues.isEmpty {
                    VStack(alignment: .leading, spacing: 7) {
                        ForEach(issues) { issue in
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                // Marcador de gravidade: cheio = grave.
                                Circle()
                                    .fill(issue.isSevere ? AtlasCodePalette.alert : AtlasCodePalette.alert.opacity(0.45))
                                    .frame(width: 5, height: 5)
                                    .offset(y: -3)
                                Text(issue.headline)
                                    .font(.system(size: 13.5))
                                    .foregroundStyle(AtlasTheme.textSecondary)
                                if let age = issue.ageNote {
                                    Text(age)
                                        .font(.system(size: 11.5))
                                        .foregroundStyle(AtlasTheme.textTertiary)
                                }
                            }
                        }
                    }
                    .padding(.top, 9)
                }

                if case .unreadable(let reason) = repo.signal {
                    Text(honestReason(reason))
                        .font(.system(size: 12))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .padding(.top, 5)
                }
                if case .scanUnavailable = repo.signal {
                    Text("não foi possível varrer agora")
                        .font(.system(size: 12))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .padding(.top, 5)
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AtlasTheme.surface.opacity(0.4), in: RoundedRectangle(cornerRadius: 14))
            .overlay(alignment: .leading) {
                // Um sinal primário: o filete. Sem moldura vermelha inteira.
                if case .exception = repo.signal {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AtlasCodePalette.alert)
                        .frame(width: 3)
                        .padding(.vertical, 12)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(AtlasTheme.separator, lineWidth: 0.5)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
        .accessibilityIdentifier("radar-repo-\(repo.slug)")
    }

    /// À direita: nada quando saudável; o chevron convida a entrar.
    @ViewBuilder
    private var trailingMark: some View {
        switch repo.signal {
        case .silent:
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
        case .exception:
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AtlasCodePalette.alert.opacity(0.8))
        case .unreadable, .scanUnavailable:
            Image(systemName: "eye.slash")
                .font(.system(size: 11))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
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
        case .silent: return "\(name), sem problemas"
        case .exception(_, let issues):
            return "\(name): " + issues.map(\.headline).joined(separator: ", ")
        case .unreadable(let reason): return "\(name), \(honestReason(reason))"
        case .scanUnavailable: return "\(name), não foi possível varrer"
        }
    }
}
