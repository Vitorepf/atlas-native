import AtlasCore
import SwiftUI
import Observation

// Cycle 043 fuse → AtlasCodeMirrorCard.swift

/// M5 · Espelho — o que sairia do Mac, e o que a varredura encontrou.
struct AtlasCodeMirrorCard: View {
    let response: AtlasCodeMirrorResponse
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        mirrorCardChrome
    }
}

extension AtlasCodeMirrorCard {
    var mirrorStatePhaseCountedID: String? {
        switch response.state {
        case .pending(let commits): return "pending-\(commits)"
        case .blocked(let rules): return "blocked-\(rules.joined(separator: "-"))"
        default: return nil
        }
    }
}

extension AtlasCodeMirrorCard {
    var mirrorStatePhaseQuietID: String? {
        switch response.state {
        case .mirrored: return "mirrored"
        case .noMirror: return "no-mirror"
        case .unknown: return "unknown"
        default: return nil
        }
    }
}

extension AtlasCodeMirrorCard {
    var mirrorStatePhaseID: String {
        mirrorStatePhaseCountedID
            ?? mirrorStatePhaseQuietID
            ?? "unknown"
    }
}

/// Só fala host e contagens reais do payload; ausência nunca vira zero fabricado.

extension AtlasCodeMirrorCard {
    func spokenMirrorLabel() -> String {
        var parts: [String] = ["Espelho"]
        parts.append(contentsOf: spokenMirrorStateParts())
        if let host = response.mirror?.host, !host.isEmpty {
            parts.append("host \(host)")
        }
        return parts.joined(separator: ", ")
    }

    static let mirrorHint = "cópia remota do repositório e varredura de segredos no Mac"
}

extension AtlasCodeMirrorCard {
    var mirrorCardChrome: some View {
        VStack(alignment: .leading, spacing: 8) {
            mirrorHeader
            headline
            blockedRulesRow
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background, in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.card))
        .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).strokeBorder(borderColor, lineWidth: 1))
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: mirrorStatePhaseID)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenMirrorLabel())
        .accessibilityHint(Self.mirrorHint)
        .accessibilityIdentifier(A11yID.codeMirror)
    }
}

extension AtlasCodeMirrorCard {
    var mirrorHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("Espelho")
                .font(AtlasFont.serif(18, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Spacer()
            if let host = response.mirror?.host {
                Text(host)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var blockedRulesRow: some View {
        if case .blocked(let rules) = response.state {
            HStack(spacing: 5) {
                ForEach(rules, id: \.self) { rule in
                    Text(rule)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasCodePalette.alert)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .overlay(Capsule().strokeBorder(AtlasCodePalette.alert.opacity(0.3), lineWidth: 1))
                        .accessibilityHidden(true)
                }
            }
            .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeMirrorCard {
    var background: Color {
        if case .blocked = response.state { return AtlasCodePalette.alert.opacity(0.05) }
        return AtlasTheme.surface.opacity(0.4)
    }

    var borderColor: Color {
        if case .blocked = response.state { return AtlasCodePalette.alert.opacity(0.35) }
        return AtlasTheme.separator
    }
}

extension AtlasCodeMirrorCard {
    func label(_ text: String, color: Color, icon: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .atlasSans(10, .semibold)
                .accessibilityHidden(true)
            Text(text)
                .atlasSans(12.5)
                .accessibilityHidden(true)
        }
        .foregroundStyle(color)
        .accessibilityHidden(true)
    }
}

extension AtlasCodeMirrorCard {
    func spokenMirrorBlockedParts(rules: [String]) -> [String] {
        var parts = ["bloqueado, segredo detectado"]
        if !rules.isEmpty {
            parts.append("regras \(rules.joined(separator: ", "))")
        }
        return parts
    }
}

extension AtlasCodeMirrorCard {
    func spokenMirrorPendingParts(commits: Int) -> [String] {
        ["\(commits) commit\(commits == 1 ? "" : "s") ainda só no Mac"]
    }
}

extension AtlasCodeMirrorCard {
    func spokenMirrorMirroredParts() -> [String]? {
        if case .mirrored = response.state {
            return ["tudo espelhado, verdade no Mac"]
        }
        return nil
    }
}

extension AtlasCodeMirrorCard {
    func spokenMirrorQuietParts() -> [String]? {
        if let mirrored = spokenMirrorMirroredParts() { return mirrored }
        switch response.state {
        case .noMirror:
            return ["sem espelho configurado"]
        case .unknown:
            return ["estado ainda não conhecido"]
        default:
            return nil
        }
    }
}

extension AtlasCodeMirrorCard {
    func spokenMirrorStateParts() -> [String] {
        if let quiet = spokenMirrorQuietParts() { return quiet }
        switch response.state {
        case .pending(let commits):
            return spokenMirrorPendingParts(commits: commits)
        case .blocked(let rules):
            return spokenMirrorBlockedParts(rules: rules)
        default:
            return ["estado ainda não conhecido"]
        }
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineBlocked: some View {
        if case .blocked = response.state {
            label(
                "segredo detectado · nada sai da máquina",
                color: AtlasCodePalette.alert,
                icon: "exclamationmark.triangle"
            )
        }
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthyActive: some View {
        switch response.state {
        case .mirrored:
            headlineHealthyMirrored
        case .pending(let commits):
            headlineHealthyPending(commits: commits)
        default:
            EmptyView()
        }
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthyMirrored: some View {
        label("tudo espelhado · a verdade fica no Mac", color: AtlasTheme.textSecondary, icon: "checkmark")
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    func headlineHealthyPending(commits: Int) -> some View {
        label(
            commits == 1 ? "1 commit ainda só no Mac" : "\(commits) commits ainda só no Mac",
            color: AtlasTheme.textSecondary,
            icon: "internaldrive"
        )
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthyNoMirror: some View {
        label("sem espelho configurado", color: AtlasTheme.textTertiary, icon: "circle.dashed")
    }

    @ViewBuilder
    var headlineHealthyUnknown: some View {
        label("espelho ainda não conhecido", color: AtlasTheme.textTertiary, icon: "questionmark.circle")
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthyQuiet: some View {
        switch response.state {
        case .noMirror:
            headlineHealthyNoMirror
        case .unknown:
            headlineHealthyUnknown
        default:
            EmptyView()
        }
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthy: some View {
        switch response.state {
        case .mirrored, .pending:
            headlineHealthyActive
        case .noMirror, .unknown:
            headlineHealthyQuiet
        default:
            EmptyView()
        }
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headline: some View {
        headlineBlocked
        headlineHealthy
    }
}


/// M5 · Espelho — fetch model; card em `AtlasCodeMirrorCard.swift`.
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
