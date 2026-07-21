import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: RepoHealth Judgment + Strip fused

// MARK: - Judgment

// MARK: - Types

/// Exclusive single-repo health face (WAVE-043).
enum AtlasCodeRepoHealthFace: Equatable {
    case unbound
    case unknown
    case clean
    case healed
    case weekActive(commits: Int, heals: Int, prevented: Int)
    case violating(Int)
    case mirrorBlocked(rules: [String])

    var productWord: String {
        switch self {
        case .unbound: return "unbound"
        case .unknown: return "unknown"
        case .clean: return "clean"
        case .healed: return "healed"
        case .weekActive: return "week_active"
        case .violating: return "violating"
        case .mirrorBlocked: return "mirror_blocked"
        }
    }

    var kicker: String {
        switch self {
        case .unbound: return "Repo"
        case .unknown: return "Varredura desconhecida"
        case .clean: return "Linha quieta"
        case .healed: return "Curado sozinho"
        case .weekActive: return "Semana ativa"
        case .violating: return "Sem retorno"
        case .mirrorBlocked: return "Espelho bloqueado"
        }
    }

    var spokenFace: String {
        switch self {
        case .unbound:
            return "repositório ainda não carregado"
        case .unknown:
            return "varredura ainda não conhecida"
        case .clean:
            return "linha principal quieta, sem sem-retorno"
        case .healed:
            return "linha quieta e curada sozinha"
        case .weekActive(let commits, let heals, let prevented):
            var parts = ["semana ativa"]
            if commits > 0 {
                parts.append(commits == 1 ? "1 commit" : "\(commits) commits")
            }
            if heals > 0 {
                parts.append(heals == 1 ? "1 cura" : "\(heals) curas")
            }
            if prevented > 0 {
                parts.append(prevented == 1 ? "1 prevenida" : "\(prevented) prevenidas")
            }
            return parts.joined(separator: ", ")
        case .violating(let n):
            return n == 1 ? "1 sem retorno" : "\(n) sem retorno"
        case .mirrorBlocked(let rules):
            if rules.isEmpty {
                return "espelho bloqueado, segredo detectado"
            }
            return "espelho bloqueado, regras \(rules.joined(separator: ", "))"
        }
    }
}

// MARK: - Judgment

/// Pure repo health grammar — face · summary · pack · spoken.
/// Attention lead: mirror blocked → violating → healed → week active → clean.
enum AtlasCodeRepoHealthJudgment {

    // MARK: Face

    @MainActor
    static func face(
        model: AtlasCodeModel,
        mirror: AtlasCodeMirrorResponse? = nil
    ) -> AtlasCodeRepoHealthFace {
        switch model.phase {
        case .idle, .loading:
            return .unbound
        case .failed:
            return .unknown
        case .loaded:
            break
        }

        if let mirror, case .blocked(let rules) = mirror.state {
            return .mirrorBlocked(rules: rules)
        }

        switch model.scanState {
        case .violating:
            let n = model.violations?.violations.count ?? 0
            return .violating(max(n, 1))
        case .unknown:
            return .unknown
        case .clean:
            break
        }

        if model.hasHealReceipt {
            return .healed
        }

        if let week = model.week, !AtlasCodeWeekUI.isQuiet(week) {
            return .weekActive(
                commits: week.commits,
                heals: week.heals,
                prevented: week.prevented
            )
        }

        return .clean
    }

    // MARK: Summary

    @MainActor
    static func summaryLine(
        model: AtlasCodeModel,
        mirror: AtlasCodeMirrorResponse? = nil
    ) -> String {
        let face = face(model: model, mirror: mirror)
        var parts: [String] = [face.kicker]

        // Always honest secondary signals when present (not invent).
        if model.hasViolations {
            let n = model.violations?.violations.count ?? 0
            if n > 0 { parts.append(n == 1 ? "1 sem retorno" : "\(n) sem retorno") }
        }
        if model.hasHealReceipt {
            parts.append("cura publicada")
        }
        if let week = model.week {
            if AtlasCodeWeekUI.isQuiet(week) {
                parts.append("semana quieta")
            } else {
                if week.commits > 0 { parts.append("\(week.commits) commits") }
                if week.heals > 0 { parts.append("\(week.heals) curas") }
                if week.prevented > 0 { parts.append("\(week.prevented) prevenidas") }
            }
        }
        if let mirror {
            switch mirror.state {
            case .blocked:
                parts.append("espelho bloqueado")
            case .pending(let n):
                parts.append(n == 1 ? "1 commit só no Mac" : "\(n) commits só no Mac")
            case .mirrored:
                parts.append("espelho ok")
            case .noMirror, .unknown:
                break
            }
        }

        // De-dupe adjacent identical kickers.
        var out: [String] = []
        for p in parts where out.last != p {
            out.append(p)
        }
        return out.joined(separator: " · ")
    }

    // MARK: Pack

    @MainActor
    static func packFacts(
        model: AtlasCodeModel,
        mirror: AtlasCodeMirrorResponse? = nil
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(model: model, mirror: mirror)
        facts.append("repo_health_face: \(face.productWord)")
        facts.append(summaryLine(model: model, mirror: mirror))

        switch model.phase {
        case .idle, .loading:
            absences.append("grafo ainda não carregado — não invente saúde")
            return (facts, absences)
        case .failed:
            absences.append("load do grafo falhou — saúde desconhecida")
            return (facts, absences)
        case .loaded:
            break
        }

        facts.append("scan: \(AtlasCodeGraphJudgment.scanWord(model.scanState))")
        facts.append("status_headline: \(model.statusHeadline)")

        if model.violations == nil {
            absences.append("violações não hidratadas neste load")
        } else if !model.hasViolations {
            facts.append("violations: 0")
        } else {
            facts.append("violations: \(model.violations?.violations.count ?? 0)")
        }

        if model.hasHealReceipt {
            facts.append("heal_receipt: present")
        } else {
            absences.append("sem recibo de cura neste recorte")
        }

        if let week = model.week {
            facts.append("week_window: \(week.window)")
            facts.append("week_commits: \(week.commits)")
            facts.append("week_heals: \(week.heals)")
            facts.append("week_prevented: \(week.prevented)")
        } else {
            absences.append("semana (week) não hidratada")
        }

        if let mirror {
            facts.append("mirror_state: \(mirrorStateWord(mirror.state))")
            if case .blocked(let rules) = mirror.state, !rules.isEmpty {
                facts.append("mirror_blocked_rules: \(rules.joined(separator: ","))")
            }
        } else {
            absences.append("espelho não hidratado neste recorte")
        }

        return (facts, absences)
    }

    static func mirrorStateWord(_ state: AtlasCodeMirrorResponse.State) -> String {
        switch state {
        case .blocked: return "blocked"
        case .mirrored: return "mirrored"
        case .pending: return "pending"
        case .noMirror: return "no_mirror"
        case .unknown: return "unknown"
        }
    }
}

// MARK: - Strip

// MARK: - Repo health strip (WAVE-043)

/// Thin exclusive health face for single-repo Código surface.
struct AtlasCodeRepoHealthStrip: View {
    let model: AtlasCodeModel
    let mirror: AtlasCodeMirrorResponse?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var face: AtlasCodeRepoHealthFace {
        AtlasCodeRepoHealthJudgment.face(model: model, mirror: mirror)
    }

    var body: some View {
        switch face {
        case .unbound:
            EmptyView()
        case .unknown, .clean, .healed, .weekActive, .violating, .mirrorBlocked:
            stripChrome
        }
    }

    private var stripChrome: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Circle()
                .fill(dotColor)
                .frame(width: 7, height: 7)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(face.kicker)
                    .font(AtlasFont.mono(9))
                    .tracking(0.7)
                    .foregroundStyle(titleColor)
                Text(AtlasCodeRepoHealthJudgment.summaryLine(model: model, mirror: mirror))
                    .font(AtlasFont.serif(12))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(face.spokenFace)
        .accessibilityIdentifier(A11yID.codeRepoHealth)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: face.productWord)
    }

    private var dotColor: Color {
        switch face {
        case .mirrorBlocked, .violating: return AtlasCodePalette.alert
        case .healed: return AtlasCodePalette.healed
        case .weekActive: return AtlasTheme.accent
        case .clean: return AtlasTheme.textTertiary
        case .unknown, .unbound: return AtlasTheme.textTertiary
        }
    }

    private var titleColor: Color {
        switch face {
        case .mirrorBlocked, .violating: return AtlasCodePalette.alert
        case .healed: return AtlasCodePalette.healed
        case .weekActive: return AtlasTheme.accent
        case .clean, .unknown, .unbound: return AtlasTheme.textTertiary
        }
    }
}
