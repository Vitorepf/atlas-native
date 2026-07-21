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
