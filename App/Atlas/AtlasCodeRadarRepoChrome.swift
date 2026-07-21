import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: RadarChrome fused

// MARK: - AtlasCodeRadarRepoChrome

struct AtlasCodeRepoRow: View {
    let repo: AtlasCodeRepoRef
    let issues: [AtlasCodeIssue]?
    /// A trunk real deste repo: a frase da issue fala o nome da linha.
    var trunk: String? = nil
    /// Nos recentes a pasta situa; dentro da pasta seria redundante.
    let showsFolder: Bool
    /// WAVE-024: scan failed / mute — never read as limpo.
    var isMute: Bool = false
    let onTap: () -> Void

    var body: some View {
        repoRowA11yChrome
    }
}

extension AtlasCodeRadarStatusCapsule {
    var alarmCapsule: some View {
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

extension AtlasCodeRadarStatusCapsule {
    /// Caption baixa — mesmo padrão da frota («frota» / «fila») sem incidente.
    var silentCaption: some View {
        Text(model.scanState == .clean ? "código" : model.headline)
            .atlasSans(11, .semibold)
            .tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.vertical, 7)
            .accessibilityHidden(true)
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

extension AtlasCodeRadarStatusCapsule {
    @ViewBuilder
    var statusSwitchBody: some View {
        Group {
            switch model.scanState {
            case .clean, .unknown:
                silentCaption
            case .violating:
                alarmCapsule
            }
        }
    }
}

// MARK: - Chrome do AtlasCodeRadarView (peel de AtlasCodeRadarSections)
// Capsules → +Capsules · Labels → +Labels

struct AtlasCodeRadarStatusCapsule: View {
    let model: AtlasCodeWorkspaceModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        // Silêncio = produto: saudável (sem violações) → caption quieta, sem
        // chrome de alarme/afirmação verde. Barulho só com exceção real.
        statusSwitchBody
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: model.scanState)
        .frame(maxWidth: .infinity, alignment: .center)
        .accessibilityLabel(spokenStatus(model: model))
        .accessibilityIdentifier(A11yID.radarStatus)
    }
}

extension AtlasCodeRadarView {
    var askPillDock: some View {
        AgenticAskDock {
            AgenticPill(
                invite: AtlasCodeRadarAskContext.invite,
                accessibilityId: A11yID.radarAskPill,
                accessibilityHintText: "Abre conversa com o contexto do workspace"
            ) {
                askDraft = ""
                showingAsk = true
            }
        }
    }

    var askConversationSheet: some View {
        ConversationView(
            client: session.client,
            threadId: askThreadId,
            title: "Código · workspace",
            emptyPrompt: AtlasCodeRadarAskContext.emptyPrompt(headline: model.headline),
            emptySuggestions: AtlasCodeRadarAskContext.emptySuggestions,
            taskKind: "code",
            // Prefer root; senão primeiro recente; nil + absence no pack se vazio.
            workspace: radarWireWorkspace,
            draft: askDraft,
            turnFacts: { [model] _ in
                AtlasCodeRadarAskContext.facts(model: model)
            },
            onThread: { askThreadId = $0 },
            hidesNavigationBack: true
        )
        .agenticAskSheetPresentation()
    }

    /// Wire workspace honesto — só o que o model já expõe (WAVE-002).
    var radarWireWorkspace: String? {
        if let root = model.workspace?.workspaceRoot?.trimmingCharacters(in: .whitespacesAndNewlines),
           !root.isEmpty {
            return root
        }
        if let slug = model.workspace?.recents.first?.slug, !slug.isEmpty {
            return slug
        }
        return nil
    }
}
// MARK: - AtlasCodeRadarFolderRow

struct AtlasCodeFolderRow: View {
    let folder: AtlasCodeFolder
    let isExpanded: Bool
    let issuesFor: (String) -> [AtlasCodeIssue]?
    let trunkFor: (String) -> String?
    var isMuteFor: (String) -> Bool = { _ in false }
    let onToggle: () -> Void
    let onOpenRepo: (String) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            folderToggleButton
            expandedRepos
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: isExpanded)
    }
}

extension AtlasCodeRepoRow {
    var repoRowLabel: some View {
        HStack(alignment: .center, spacing: 12) {
            repoRowLeading
            Spacer(minLength: 6)
            repoRowTrailing
        }
        .padding(.vertical, 13)
        .contentShape(Rectangle())
    }
}

extension AtlasCodeRepoRow {
    var repoRowLeading: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 7) {
                Text(repo.name)
                    .atlasSans(15, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                repoFolderBadge
            }
            repoRowIssues
        }
        .accessibilityHidden(true)
    }
}

extension AtlasCodeRepoRow {
    @ViewBuilder
    var repoFolderBadge: some View {
        if showsFolder, let folder = repo.folder {
            Text(folder)
                .atlasSans(10)
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.horizontal, 6)
                .padding(.vertical, 1.5)
                .background(Capsule().fill(AtlasTheme.surface))
                .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeRepoRow {
    @ViewBuilder
    var repoRowIssues: some View {
        if isMute {
            // WAVE-024: mute never reads as clean.
            HStack(spacing: 6) {
                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    .atlasSans(9, .semibold)
                    .accessibilityHidden(true)
                Text("\(AtlasCodeRadarJudgment.muteBadgeLabel) · \(AtlasCodeRadarJudgment.muteSpoken)")
                    .atlasSans(12)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .accessibilityHidden(true)
            }
        } else if let issues, let first = issues.first {
            HStack(spacing: 6) {
                Circle()
                    .fill(first.isSevere ? AtlasCodePalette.alert : AtlasCodePalette.alert.opacity(0.45))
                    .frame(width: 4.5, height: 4.5)
                    .accessibilityHidden(true)
                Text(issues.count == 1 ? first.headline(trunk: trunk) : "\(first.headline(trunk: trunk)) · mais \(issues.count - 1) alerta\(issues.count - 1 == 1 ? "" : "s")")
                    .atlasSans(12)
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
                    .accessibilityHidden(true)
            }
        }
    }
}

extension AtlasCodeRepoRow {
    @ViewBuilder
    var repoRowTrailing: some View {
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
}
// MARK: - AtlasCodeRadarLoadJudgment

// MARK: - Types

/// Exclusive multi-repo Radar screen face (WAVE-067).
enum AtlasCodeRadarScreenFace: Equatable {
    case loading
    case failed(String?)
    case empty
    case ready(Int)

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .failed: return "failed"
        case .empty: return "empty"
        case .ready: return "ready"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading:
            return "lendo o workspace"
        case .failed(let message):
            if let message, !message.isEmpty {
                return "workspace indisponível, \(message)"
            }
            return "workspace indisponível"
        case .empty:
            return "nenhum repositório neste workspace"
        case .ready(let n):
            return n == 1 ? "1 repositório" : "\(n) repositórios"
        }
    }

    var phaseID: String {
        switch self {
        case .loading: return "loading"
        case .failed: return "failed"
        case .empty: return "loaded-empty"
        case .ready(let n): return "loaded-\(n)"
        }
    }
}

// MARK: - Judgment

/// Pure Radar screen load grammar — face · spoken · phaseID · pack.
enum AtlasCodeRadarLoadJudgment {

    static let shellHint = "pastas, recentes e sem retorno verificados do seu código"

    static func face(
        phase: LoadPhase,
        repositoryCount: Int?,
        failMessage: String? = nil
    ) -> AtlasCodeRadarScreenFace {
        switch phase {
        case .idle, .loading:
            return .loading
        case .failed(let message):
            let published = failMessage ?? message
            return .failed(published.isEmpty ? nil : published)
        case .loaded:
            let n = repositoryCount ?? 0
            if n <= 0 { return .empty }
            return .ready(n)
        }
    }

    static func spokenShell(face: AtlasCodeRadarScreenFace) -> String {
        "Código, workspace do operador, \(face.spokenFace)"
    }

    static func spokenShell(
        phase: LoadPhase,
        repositoryCount: Int?,
        failMessage: String? = nil
    ) -> String {
        spokenShell(
            face: face(
                phase: phase,
                repositoryCount: repositoryCount,
                failMessage: failMessage
            )
        )
    }

    static func packFacts(
        phase: LoadPhase,
        repositoryCount: Int?,
        failMessage: String? = nil
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(
            phase: phase,
            repositoryCount: repositoryCount,
            failMessage: failMessage
        )
        facts.append("radar_screen_face: \(face.productWord)")
        switch face {
        case .loading:
            absences.append("workspace radar ainda carregando")
        case .failed(let msg):
            absences.append("workspace radar falhou")
            if let msg, !msg.isEmpty { facts.append("radar_error: \(msg)") }
        case .empty:
            absences.append("workspace sem repositórios")
            facts.append("radar_repos: 0")
        case .ready(let n):
            facts.append("radar_repos: \(n)")
        }
        return (facts, absences)
    }
}

// MARK: - AtlasCodeHealVetoJudgment

// MARK: - Types

/// Exclusive heal veto face for Código receipt (WAVE-048).
enum AtlasCodeHealVetoFace: Equatable {
    case absent
    case completed
    case blocked(String)
    case vetoOpen
    case vetoClosed
    case undoFailed(String)

    var productWord: String {
        switch self {
        case .absent: return "absent"
        case .completed: return "completed"
        case .blocked: return "blocked"
        case .vetoOpen: return "veto_open"
        case .vetoClosed: return "veto_closed"
        case .undoFailed: return "undo_failed"
        }
    }

    var kicker: String {
        switch self {
        case .absent: return "Cura"
        case .completed: return "Curado sozinho"
        case .blocked: return "Cura bloqueada"
        case .vetoOpen: return "Veto aberto"
        case .vetoClosed: return "Veto encerrado"
        case .undoFailed: return "Veto falhou"
        }
    }

    var spokenFace: String {
        switch self {
        case .absent:
            return "sem recibo de cura"
        case .completed:
            return "curado sozinho, sem janela de veto ativa"
        case .blocked(let reason):
            return "cura bloqueada, \(reason)"
        case .vetoOpen:
            return "janela de veto aberta, desfazer com recibo disponível"
        case .vetoClosed:
            return "janela de veto encerrada"
        case .undoFailed(let message):
            return "falha ao desfazer, \(message)"
        }
    }
}

// MARK: - Judgment

/// Pure heal veto grammar — face · canVeto · pack · spoken.
enum AtlasCodeHealVetoJudgment {

    static func completedStepCount(_ heal: AtlasCodeHealResponse) -> Int {
        heal.stepReceipts.filter { $0.status == "completed" }.count
    }

    static func undoExpiresAt(_ heal: AtlasCodeHealResponse) -> String? {
        heal.stepReceipts.compactMap(\.undoExpiresAt).first
    }

    static func canVeto(_ heal: AtlasCodeHealResponse) -> Bool {
        heal.healId != nil && AtlasCodeUndoWindow.isOpen(expiresAt: undoExpiresAt(heal))
    }

    static func face(
        heal: AtlasCodeHealResponse?,
        undoError: String?
    ) -> AtlasCodeHealVetoFace {
        if let err = undoError?.trimmingCharacters(in: .whitespacesAndNewlines), !err.isEmpty {
            return .undoFailed(err)
        }
        guard let heal else { return .absent }
        if let blocked = heal.blocked, !blocked.isEmpty {
            return .blocked(blocked)
        }
        if canVeto(heal) {
            return .vetoOpen
        }
        if completedStepCount(heal) > 0 {
            // Completed but window closed or no healId for undo.
            if heal.healId != nil {
                return .vetoClosed
            }
            return .completed
        }
        return .completed
    }

    static func packFacts(
        heal: AtlasCodeHealResponse?,
        undoError: String?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(heal: heal, undoError: undoError)
        facts.append("heal_veto_face: \(face.productWord)")
        guard let heal else {
            absences.append("recibo de cura não hidratado neste recorte")
            return (facts, absences)
        }
        facts.append("heal_mode: \(heal.mode)")
        facts.append("heal_steps: \(heal.stepReceipts.count)")
        facts.append("heal_completed_steps: \(completedStepCount(heal))")
        facts.append("can_veto: \(canVeto(heal))")
        if let note = AtlasCodeUndoWindow.note(expiresAt: undoExpiresAt(heal)) {
            facts.append("veto_window: \(note)")
        } else {
            absences.append("janela de veto sem nota publicada")
        }
        if let err = undoError, !err.isEmpty {
            facts.append("undo_error: \(err)")
        } else {
            absences.append("nenhuma falha de veto neste recorte")
        }
        if heal.healId == nil {
            absences.append("heal_id ausente — veto indisponível")
        }
        return (facts, absences)
    }

    static func spokenUndoError(_ err: String) -> String {
        "falha ao desfazer, \(err)"
    }

    static let curedAloneOpenReceiptLabel = "curado sozinho, ver recibo de cura"

    static func spokenSheet(
        heal: AtlasCodeHealResponse,
        undoError: String?
    ) -> String {
        var parts = ["recibo de cura", heal.mode]
        let face = face(heal: heal, undoError: undoError)
        parts.append(face.spokenFace)
        if heal.stepReceipts.isEmpty {
            parts.append("sem passos no recibo")
        } else {
            let done = completedStepCount(heal)
            parts.append("\(heal.stepReceipts.count) passos, \(done) concluídos")
        }
        return parts.joined(separator: ", ")
    }
}

// MARK: - AtlasCodeAskPillJudgment

// MARK: - Types

/// Exclusive código ask-pill face (WAVE-062).
enum AtlasCodeAskPillFace: Equatable {
    case invite
    case anchoring
    case legend

    var productWord: String {
        switch self {
        case .invite: return "invite"
        case .anchoring: return "anchoring"
        case .legend: return "legend"
        }
    }

    var spokenFace: String {
        switch self {
        case .invite:
            return "convidar conversa sobre o repositório"
        case .anchoring:
            return "grafo recortado nos commits da resposta"
        case .legend:
            return "recortado com legenda de âncora"
        }
    }
}

// MARK: - Judgment

/// Pure ask-pill grammar — face · spoken · phaseID · pack.
enum AtlasCodeAskPillJudgment {

    static let pillHint = "abre conversa sobre este repositório"
    static let clearLabel = "mostrar tudo no grafo"
    static let clearHint = "remove o recorte dos commits da resposta"
    static let clearCommitRefLabel = "Limpar referência do commit"
    static let askCommitLabel = "perguntar ao Atlas sobre este commit"
    static func spokenUserQuote(_ quote: String) -> String {
        "sua frase: \(quote)"
    }

    static func face(
        isAnchoring: Bool,
        anchorLegend: String?
    ) -> AtlasCodeAskPillFace {
        guard isAnchoring else { return .invite }
        let legend = anchorLegend?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !legend.isEmpty { return .legend }
        return .anchoring
    }

    static func spokenPill(
        isAnchoring: Bool,
        anchorLegend: String?
    ) -> String {
        let face = face(isAnchoring: isAnchoring, anchorLegend: anchorLegend)
        switch face {
        case .invite:
            return "Conversar com o Atlas sobre este repositório"
        case .anchoring:
            return "Conversar com o Atlas, grafo recortado nos commits da resposta"
        case .legend:
            let legend = anchorLegend?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return "Conversar com o Atlas, \(legend)"
        }
    }

    /// Animation / phase token (stable for reduceMotion gate).
    static func phaseID(
        isAnchoring: Bool,
        anchorLegend: String?
    ) -> String {
        let face = face(isAnchoring: isAnchoring, anchorLegend: anchorLegend)
        switch face {
        case .invite:
            return "invite"
        case .anchoring:
            return "anchoring-default"
        case .legend:
            return "anchoring-\(anchorLegend ?? "default")"
        }
    }

    static func packFacts(
        isAnchoring: Bool,
        anchorLegend: String?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(isAnchoring: isAnchoring, anchorLegend: anchorLegend)
        facts.append("ask_pill_face: \(face.productWord)")
        switch face {
        case .invite:
            absences.append("pílula em convite (sem âncora)")
        case .anchoring:
            facts.append("ask_pill_anchoring: true")
            absences.append("âncora sem legenda textual neste recorte")
        case .legend:
            facts.append("ask_pill_anchoring: true")
            if let legend = anchorLegend?.trimmingCharacters(in: .whitespacesAndNewlines),
               !legend.isEmpty {
                facts.append("ask_pill_legend: \(legend)")
            }
        }
        return (facts, absences)
    }
}

// MARK: - AtlasCodeRepoHealthJudgment

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
