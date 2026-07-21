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
