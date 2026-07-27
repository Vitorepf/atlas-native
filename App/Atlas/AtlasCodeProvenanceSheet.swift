import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: ProvenanceSheet + Header fused

// MARK: - Sheet

// MARK: - Host

extension AtlasCodeProvenanceSheet {
    /// WAVE-057: body gate + face from Judgment.
    func hasLoadedBody(_ provenance: AtlasCodeProvenance) -> Bool {
        AtlasCodeProvenanceJudgment.hasLoadedBody(provenance)
    }

    var provenanceFace: AtlasCodeProvenanceFace {
        AtlasCodeProvenanceJudgment.face(phase: phase)
    }

    var provenanceContentPhaseID: String {
        provenanceFace.contentPhaseID
    }

    func spokenLoading() -> String {
        AtlasCodeProvenanceFace.loading.spokenFace
    }

    func spokenFailed(_ message: String) -> String {
        AtlasCodeProvenanceFace.failed(message).spokenFace
    }

    static let spokenSheetHint = "estado do commit, lei aplicável e o que o ledger registrou"
    static let spokenAskHint = "abre conversa com este commit no assunto"

    func spokenStateKicker() -> String {
        AtlasCodeProvenanceJudgment.spokenStateKicker(state: state, trunk: trunk)
    }

    func spokenHeaderTitle() -> String {
        AtlasCodeProvenanceJudgment.spokenTitle(node: node)
    }

    var provenanceSheetSpokenLabel: String {
        AtlasCodeProvenanceJudgment.spokenSheet(
            node: node,
            state: state,
            trunk: trunk,
            phase: phase
        )
    }
}

extension AtlasCodeProvenanceSheet {
    func spokenLawCitation() -> String? {
        guard state == .violating, let ruleId else { return nil }
        var parts = [AtlasCodeIssue.law(ruleId, trunk: trunk)]
        if let ruleCanon = ruleCanon?.nonEmpty { parts.append(ruleCanon) }
        return parts.joined(separator: ", ")
    }
}

extension AtlasCodeProvenanceSheet {
    var provenanceBodyShell: some View {
        provenanceSheetChrome(provenanceSurface)
    }
}

extension AtlasCodeProvenanceSheet {
    func provenanceSheetChrome<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityElement(children: .contain)
            .accessibilityLabel(provenanceSheetSpokenLabel)
            .accessibilityHint(Self.spokenSheetHint)
            .sheet(item: $whyTarget) { target in
                AtlasCodeWhySheet(client: client, repo: repo, file: target.path)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
    }
}

extension AtlasCodeProvenanceSheet {
    var provenanceScrollStack: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                lawCitation
                askButton
                provenanceContent(whyTarget: $whyTarget)
                hashFooter
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(22)
            .padding(.bottom, 12)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: provenanceContentPhaseID)
        }
        .scrollIndicators(.hidden)
    }
}

extension AtlasCodeProvenanceSheet {
    var provenanceSurface: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            provenanceScrollStack
        }
    }
}

// MARK: - Folha: por que esta linha existe (C23)

/// A folha responde, em ordem, as perguntas de quem abre um commit: em que
/// estado ele está, o que ele diz, por que existe, e o que ele tocou.
/// O hash fecha a folha — máquina embaixo do vidro (lei 6).
/// Chrome → AtlasCodeProvenanceSheet+Chrome.swift
/// Scroll → AtlasCodeProvenanceSheet+Scroll.swift
/// Surface → AtlasCodeProvenanceSheet+Surface.swift
struct AtlasCodeProvenanceSheet: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var whyTarget: AtlasCodeProvenanceWhyTarget?
    let client: AtlasClient
    let repo: String
    let node: AtlasCodeGraphNode
    let state: AtlasCodeNodeState
    let ruleId: String?
    /// O doc que sustenta a acusação. Ausente = a regra ainda não tem lei
    /// escrita, e isso é dito calando — nunca com um caminho plausível.
    let ruleCanon: String?
    /// A trunk real — a lei citada fala o nome da linha, nunca "main" no chute.
    let trunk: String?
    let phase: AtlasCodeProvenanceModel.Phase
    /// A saída do beco: daqui o operador fala com o agente SOBRE este commit.
    let onAsk: () -> Void

    var body: some View {
        provenanceBodyShell
    }
}

// MARK: - Body

// MARK: - Ask / chrome actions

extension AtlasCodeProvenanceSheet {
    /// A porta para o agente, com o commit já no assunto.
    var askButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onAsk()
        } label: {
            askButtonLabel
        }
        .buttonStyle(PressableScale())
        .accessibilityIdentifier(A11yID.codeProvenanceAsk)
        .accessibilityLabel(AtlasCodeAskPillJudgment.spokenAskCommit)
        .accessibilityHint(Self.spokenAskHint)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var askButtonLabelLead: some View {
        Text("✦")
            .font(AtlasFont.serif(12))
            .foregroundStyle(AtlasTheme.accent)
            .accessibilityHidden(true)
        Text(AtlasCodeAskPillJudgment.spokenAskCommit)
            .font(AtlasFont.serifItalic(14))
            .foregroundStyle(AtlasTheme.textSecondary)
            .accessibilityHidden(true)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var askButtonLabelTrailing: some View {
        Spacer(minLength: 0)
        Image(systemName: "arrow.up.right")
            .atlasSans(10, .semibold)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}

extension AtlasCodeProvenanceSheet {
    var askButtonLabel: some View {
        HStack(spacing: 8) {
            askButtonLabelLead
            askButtonLabelTrailing
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .atlasCard(cornerRadius: AtlasTheme.Radius.control)
        .contentShape(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
    }
}

extension AtlasCodeProvenanceSheet {
    func block(_ title: String, @ViewBuilder body: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title.uppercased())
                .atlasSans(8.5, .semibold)
                .tracking(1.2)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            body()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
    }
}

extension AtlasCodeProvenanceSheet {
    var provenanceLoadingContent: some View {
        TraceEvidenceLoading(text: "lendo o ledger…", reduceMotion: reduceMotion)
            .padding(.top, 2)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceContent(whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>) -> some View {
        switch phase {
        case .idle, .loading:
            provenanceLoadingContent
        case .failed(let message):
            provenanceFailed(message)
        case .loaded(let provenance):
            provenanceLoadedBody(provenance, whyTarget: whyTarget)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailedDetail(_ message: String) -> some View {
        if let detail = message.nonEmpty {
            Text(detail)
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasCodePalette.alert)
                .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailedA11y<Content: View>(_ content: Content, message: String) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenFailed(message))
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailedBody(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            provenanceFailedTitle
            provenanceFailedDetail(message)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailedStack(_ message: String) -> some View {
        provenanceFailedA11y(provenanceFailedBody(message), message: message)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var provenanceFailedTitle: some View {
        Text(AtlasCodeProvenanceJudgment.productProvenanceUnavailable)
            .font(AtlasFont.serifItalic(15))
            .foregroundStyle(AtlasTheme.textSecondary)
            .accessibilityHidden(true)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceFailed(_ message: String) -> some View {
        provenanceFailedStack(message)
    }
}

extension AtlasCodeProvenanceSheet {
    func provenanceFileButton(
        _ file: AtlasCodeFileChange,
        index: Int,
        whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>
    ) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            whyTarget.wrappedValue = AtlasCodeProvenanceWhyTarget(path: file.path)
        } label: {
            AtlasCodeFileRow(file: file, accessibilityIdentifier: A11yID.whyFileRow(index))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(A11yID.whyFileRow(index))
    }
}


// MARK: - Files / sections body

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func filesSection(
        _ provenance: AtlasCodeProvenance,
        whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>
    ) -> some View {
        if !provenance.files.isEmpty {
            filesSectionBody(provenance, whyTarget: whyTarget)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    func filesSectionBody(
        _ provenance: AtlasCodeProvenance,
        whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>
    ) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            filesSectionHeader
            provenanceFilesList(provenance, whyTarget: whyTarget)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    var filesSectionHeader: some View {
        Text(AtlasCodeProvenanceJudgment.productFilesKicker)
            .atlasSans(8.5, .semibold)
            .tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier(A11yID.codeCommitFiles)
    }
}

extension AtlasCodeProvenanceSheet {
    func provenanceFilesList(
        _ provenance: AtlasCodeProvenance,
        whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>
    ) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(provenance.files.enumerated()), id: \.element.id) { index, file in
                if index > 0 {
                    Divider().overlay(AtlasTheme.separator.opacity(0.5))
                }
                provenanceFileButton(file, index: index, whyTarget: whyTarget)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func lawCanonText(_ ruleCanon: String) -> some View {
        Text(ruleCanon)
            .font(AtlasFont.mono(9.5))
            .foregroundStyle(AtlasTheme.textTertiary.opacity(0.85))
            .lineLimit(1)
            .truncationMode(.head)
            .accessibilityHidden(true)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func lawRuleText(_ ruleId: String) -> some View {
        Text(AtlasCodeIssue.law(ruleId, trunk: trunk))
            .font(AtlasFont.serif(14, .semibold))
            .foregroundStyle(AtlasCodePalette.alert)
            .accessibilityHidden(true)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func lawCitationBody(ruleId: String) -> some View {
        lawCitationChrome(
            VStack(alignment: .leading, spacing: 3) {
                lawRuleText(ruleId)
                if let ruleCanon = ruleCanon?.nonEmpty {
                    lawCanonText(ruleCanon)
                }
            }
        )
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var lawCitationChrome: some View {
        if state == .violating, let ruleId, spokenLawCitation() != nil {
            lawCitationBody(ruleId: ruleId)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    func lawCitationChrome<Content: View>(_ content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft)
                    .fill(AtlasCodePalette.alert.opacity(0.08))
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenLawCitation() ?? "")
            .accessibilityIdentifier(A11yID.codeProvenanceLaw)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceGatesObra(_ provenance: AtlasCodeProvenance) -> some View {
        if let gates = provenance.gates, !gates.isEmpty {
            block("Prova no ledger") { AtlasCodeChipRow(items: gates) }
        }
        if let obra = provenance.obra, !obra.isEmpty {
            block("Obra") { AtlasCodeChipRow(items: obra) }
        }
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceLoadedBody(_ provenance: AtlasCodeProvenance, whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>) -> some View {
        if hasLoadedBody(provenance) {
            VStack(alignment: .leading, spacing: 18) {
                provenanceProseBlocks(provenance)
                provenanceGatesObra(provenance)
                filesSection(provenance, whyTarget: whyTarget)
            }
        }
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func provenanceProseBlocks(_ provenance: AtlasCodeProvenance) -> some View {
        if let body = provenance.commitBody?.nonEmpty {
            Text(AtlasCodeCommitBody.prose(body))
                .font(AtlasFont.serif(15))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier(A11yID.codeCommitBody)
        }

        if let quote = provenance.operatorQuote?.nonEmpty {
            pullQuote(quote)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    var pullQuoteBar: some View {
        Rectangle()
            .fill(AtlasTheme.accent.opacity(0.55))
            .frame(width: 2)
    }
}

extension AtlasCodeProvenanceSheet {
    func pullQuoteStack(_ quote: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("\u{201C}\(quote)\u{201D}")
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text(AtlasCodeProvenanceJudgment.productYourPhrase)
                .atlasSans(10)
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    func pullQuote(_ quote: String) -> some View {
        HStack(alignment: .top, spacing: 11) {
            pullQuoteBar
            pullQuoteStack(quote)
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityLabel(AtlasCodeAskPillJudgment.spokenUserQuote(quote))
    }
}

// MARK: - Law citation

extension AtlasCodeProvenanceSheet {
    /// A lei que sustenta a acusação — e o documento que a prova.
    @ViewBuilder
    var lawCitation: some View {
        lawCitationChrome
    }
}

// MARK: - Header

extension AtlasCodeProvenanceSheet {
    var stateLabelHealthy: String? {
        switch state {
        case .onMain: return "NA MAIN"
        case .healed: return "CURADO"
        default: return nil
        }
    }
}

extension AtlasCodeProvenanceSheet {
    var stateLabelViolating: String {
        ruleId.map { "FORA DA LINHA · \(AtlasCodeIssue.law($0, trunk: trunk).uppercased())" } ?? "FORA DA LINHA"
    }
}

extension AtlasCodeProvenanceSheet {
    var stateLabel: String {
        if let healthy = stateLabelHealthy { return healthy }
        switch state {
        case .violating: return stateLabelViolating
        case .history: return "HISTÓRIA"
        default: return "HISTÓRIA"
        }
    }
}

extension AtlasCodeProvenanceSheet {
    /// Autor · agente · quando. O agente só aparece quando o ledger respondeu.
    var dateline: String {
        let author = node.authorName.isEmpty ? node.authorEmail : node.authorName
        var parts = [author]
        if case .loaded(let provenance) = phase, !provenance.agent.isEmpty {
            parts.append(provenance.agentLabel)
        }
        parts.append("há \(AtlasCodeRelativeTime.short(from: node.authoredAt))")
        return parts.joined(separator: " · ")
    }
}

extension AtlasCodeProvenanceSheet {
    var headerDatelineBlock: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(dateline)
                .font(AtlasFont.mono(9.5))
                .foregroundStyle(AtlasTheme.textTertiary)
            if case .loaded(let provenance) = phase, let headline = provenance.diffHeadline {
                Text(headline)
                    .font(AtlasFont.mono(9.5))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
            }
        }
    }
}

extension AtlasCodeProvenanceSheet {
    var hashFooter: some View {
        Text(node.hash)
            .font(AtlasFont.mono(9))
            .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
            .textSelection(.enabled)
            .padding(.top, 2)
            .accessibilityLabel(AtlasCodeProvenanceJudgment.spokenCommitHash)
    }
}

extension AtlasCodeProvenanceSheet {
    var headerStateKickerGlyph: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(AtlasCodePalette.color(for: state))
                .frame(width: 6, height: 6)
                .accessibilityHidden(true)
            Text(stateLabel)
                .atlasSans(10, .bold)
                .tracking(1.4)
                .foregroundStyle(AtlasCodePalette.color(for: state))
                .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    var headerStateKicker: some View {
        headerStateKickerGlyph
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenStateKicker())
            .accessibilityIdentifier(A11yID.codeProvenanceState)
    }
}

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var headerTitle: some View {
        Group {
            if let message = node.message?.nonEmpty {
                Text(message)
                    .font(AtlasFont.serif(22, .semibold))
            } else {
                Text(String(node.hash.prefix(8)))
                    .font(AtlasFont.mono(22, .semibold))
            }
        }
        .foregroundStyle(AtlasTheme.textPrimary)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityLabel(spokenHeaderTitle())
    }
}

// MARK: - Cabeçalho da folha de proveniência (C23)
// Meta → AtlasCodeProvenanceHeader+Meta.swift · Dateline → +Dateline.swift
// Title → AtlasCodeProvenanceHeader+Title.swift
// State → AtlasCodeProvenanceHeader+StateKicker.swift

extension AtlasCodeProvenanceSheet {
    var header: some View {
        VStack(alignment: .leading, spacing: 9) {
            headerStateKicker
            headerTitle
            headerDatelineBlock
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isHeader)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Why target DTO

struct AtlasCodeProvenanceWhyTarget: Identifiable {
    let path: String
    var id: String { path }
}

// MARK: - AtlasCodeProvenanceJudgment

// MARK: - Types

/// Exclusive commit-provenance drill face (WAVE-057).
enum AtlasCodeProvenanceFace: Equatable {
    case loading
    case failed(String)
    case empty
    case body(files: Int)

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .failed: return "failed"
        case .empty: return "empty"
        case .body: return "body"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading:
            return "lendo proveniência do commit"
        case .failed(let message):
            let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { return "proveniência indisponível" }
            return "proveniência indisponível, \(trimmed)"
        case .empty:
            return "ledger sem detalhe neste recorte"
        case .body(let files):
            return files == 1
                ? "1 arquivo na proveniência"
                : "\(files) arquivos na proveniência"
        }
    }

    var contentPhaseID: String {
        switch self {
        case .loading: return "loading"
        case .failed: return "failed"
        case .empty: return "loaded-empty"
        case .body(let files): return "loaded-\(files)"
        }
    }
}

// MARK: - Judgment

/// Pure provenance drill grammar — face · body gate · state kicker · pack.
enum AtlasCodeProvenanceJudgment {

    static func hasLoadedBody(_ provenance: AtlasCodeProvenance) -> Bool {
        provenance.commitBody?.nonEmpty != nil
            || provenance.operatorQuote?.nonEmpty != nil
            || !(provenance.gates?.isEmpty ?? true)
            || !(provenance.obra?.isEmpty ?? true)
            || !provenance.files.isEmpty
    }

    static func face(
        phase: AtlasCodeProvenanceModel.Phase
    ) -> AtlasCodeProvenanceFace {
        switch phase {
        case .idle, .loading:
            return .loading
        case .failed(let message):
            return .failed(message)
        case .loaded(let provenance):
            if hasLoadedBody(provenance) {
                return .body(files: provenance.files.count)
            }
            return .empty
        }
    }

    /// Product state kicker aligned with commit-row / graph vocabulary.
    static func spokenStateKicker(
        state: AtlasCodeNodeState,
        trunk: String?
    ) -> String {
        let linha = trunk?.nonEmpty ?? "main"
        switch state {
        case .onMain: return "na \(linha)"
        case .healed: return "curado"
        case .violating: return "fora da \(linha)"
        case .history: return "história"
        }
    }

    static let spokenCommitHash = "hash do commit"
    static let productFilesKicker = "ARQUIVOS"
    static let productWhyFileKicker = "POR QUE ESTE ARQUIVO EXISTE"
    static let productUndoWithReceipt = "Desfazer — com recibo"
    static let productYourPhrase = "sua frase"

    static let productProvenanceUnavailable = "proveniência indisponível"
    static let productYouWereNotNeeded = "você não foi necessário"
    static let productNoStepsInReceipt = "sem passos registrados no recibo"
    static let productReadingFileHistory = "lendo a história do arquivo…"
    static let productBiographyUnavailable = "biografia indisponível"
    static let productNoFileHistory = "este arquivo não tem história neste recorte"
    static let productNoProvenanceRecorded = "sem proveniência registrada"
    static func productBlocked(_ reason: String) -> String { "bloqueado · \(reason)" }

    static func spokenTitle(node: AtlasCodeGraphNode) -> String {
        node.message?.nonEmpty ?? String(node.hash.prefix(8))
    }

    static func spokenSheet(
        node: AtlasCodeGraphNode,
        state: AtlasCodeNodeState,
        trunk: String?,
        phase: AtlasCodeProvenanceModel.Phase
    ) -> String {
        let face = face(phase: phase)
        var parts = [
            "proveniência do commit",
            spokenTitle(node: node),
            spokenStateKicker(state: state, trunk: trunk),
            face.spokenFace
        ]
        if case .loaded(let provenance) = phase, let headline = provenance.diffHeadline {
            parts.append(headline)
        }
        return parts.joined(separator: ", ")
    }

    static func packFacts(
        node: AtlasCodeGraphNode,
        state: AtlasCodeNodeState,
        trunk: String?,
        phase: AtlasCodeProvenanceModel.Phase,
        ruleId: String?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(phase: phase)
        facts.append("provenance_face: \(face.productWord)")
        facts.append("commit: \(String(node.hash.prefix(7)))")
        facts.append("row_state: \(AtlasCodeGraphJudgment.productWord(for: state))")
        if let ruleId {
            facts.append("rule: \(ruleId)")
        }
        switch face {
        case .loading:
            absences.append("proveniência ainda carregando")
        case .failed(let msg):
            absences.append("proveniência falhou")
            if !msg.isEmpty { facts.append("provenance_error: \(msg)") }
        case .empty:
            absences.append("ledger sem detalhe neste recorte")
        case .body(let files):
            facts.append("provenance_files: \(files)")
            if case .loaded(let provenance) = phase {
                if provenance.agent.isEmpty {
                    absences.append("agente de proveniência ausente")
                } else {
                    facts.append("provenance_agent: \(provenance.agent)")
                }
                if let obra = provenance.obra, !obra.isEmpty {
                    facts.append("obra: \(obra)")
                }
                let filePack = packFileFacts(provenance.files)
                facts.append(contentsOf: filePack.facts)
                absences.append(contentsOf: filePack.absences)
            }
        }
        return (facts, absences)
    }

    // MARK: File row spoken (WAVE-101 · was AtlasCodeFileRowA11y)

    static func spokenFile(_ file: AtlasCodeFileChange) -> String {
        var parts = [file.path, verb(for: file.status)]
        if let from = file.renamedFrom { parts.append("de \(from)") }
        if let additions = file.additions, let deletions = file.deletions {
            parts.append("\(additions) linhas adicionadas")
            parts.append("\(deletions) removidas")
        } else {
            parts.append("arquivo binário")
        }
        return parts.joined(separator: ", ")
    }

    static func verb(for status: AtlasCodeFileStatus) -> String {
        verbMutate(for: status) ?? verbTransform(for: status)
    }

    static func verbMutate(for status: AtlasCodeFileStatus) -> String? {
        switch status {
        case .added: return "adicionado"
        case .modified: return "alterado"
        case .deleted: return "removido"
        default: return nil
        }
    }

    static func productVerbRename(for status: AtlasCodeFileStatus) -> String? {
        switch status {
        case .renamed: return "renomeado"
        case .copied: return "copiado"
        default: return nil
        }
    }

    static func verbTransform(for status: AtlasCodeFileStatus) -> String {
        if let rename = productVerbRename(for: status) { return rename }
        switch status {
        case .typeChanged: return "tipo alterado"
        case .unknown: return "mudança desconhecida"
        default: return verbMutate(for: status) ?? "mudança desconhecida"
        }
    }

    static func packFileFacts(
        _ files: [AtlasCodeFileChange]
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        facts.append("prov_files_total: \(files.count)")
        if files.isEmpty {
            absences.append("nenhum arquivo na proveniência")
            return (facts, absences)
        }
        for file in files.prefix(5) {
            facts.append("prov_file_sample: \(file.path) · \(verb(for: file.status))")
        }
        return (facts, absences)
    }
}

// MARK: - AtlasCodeHealReceiptSheet

// MARK: - Folha: Recibo de Cura (C25 — fato consumado, só veto)
// WAVE-009: fused instrument — silence when healthy, vocab “curado sozinho”.

struct AtlasCodeHealReceiptSheet: View {
    let heal: AtlasCodeHealResponse
    /// WAVE-048: published undo failure from model (never invent).
    var undoError: String? = nil
    let onUndo: () -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                masthead
                healStatusLines
                undoErrorLine
                receiptStepsOrEmpty
                receiptUndoFooter
                Spacer(minLength: 0)
            }
            .padding(22)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: canUndo)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: undoError)
        }
        .accessibilityIdentifier(A11yID.codeHealReceiptSheet)
        .accessibilityLabel(spokenSheetLabel())
        .accessibilityValue(vetoFace.productWord)
    }

    // MARK: - Gates (WAVE-048: Judgment-owned)

    var vetoFace: AtlasCodeHealVetoFace {
        AtlasCodeHealVetoJudgment.face(heal: heal, undoError: undoError)
    }

    var completedStepCount: Int {
        AtlasCodeHealVetoJudgment.completedStepCount(heal)
    }
    var hasCompletedHeal: Bool { completedStepCount > 0 }

    var undoExpiresAt: String? {
        AtlasCodeHealVetoJudgment.undoExpiresAt(heal)
    }

    var canUndo: Bool {
        AtlasCodeHealVetoJudgment.canVeto(heal)
    }

    // MARK: - Chrome

    var masthead: some View {
        HStack(spacing: 7) {
            Image(systemName: hasCompletedHeal ? "checkmark" : "exclamationmark.triangle")
                .atlasSans(10, .bold)
                .accessibilityHidden(true)
            Text(hasCompletedHeal
                 ? "CURADO SOZINHO · \(heal.mode.uppercased())"
                 : "CURA · \(heal.mode.uppercased())")
                .atlasSans(10, .bold)
                .tracking(1.2)
                .accessibilityHidden(true)
        }
        .foregroundStyle(hasCompletedHeal ? AtlasCodePalette.healed : AtlasTheme.textTertiary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenMastheadLabel())
    }

    @ViewBuilder
    var healStatusLines: some View {
        if hasCompletedHeal {
            Text(AtlasCodeProvenanceJudgment.productYouWereNotNeeded)
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(spokenSilenceLabel())
        }
        if let blocked = heal.blocked, !blocked.isEmpty {
            Text(AtlasCodeProvenanceJudgment.productBlocked(blocked))
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasCodePalette.alert)
                .accessibilityLabel(spokenBlockedLabel(blocked))
        }
    }

    @ViewBuilder
    var receiptStepsOrEmpty: some View {
        if heal.stepReceipts.isEmpty {
            Text(AtlasCodeProvenanceJudgment.productNoStepsInReceipt)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel(spokenEmptyStepsLabel())
        } else {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(heal.stepReceipts.enumerated()), id: \.element.id) { index, receipt in
                    stepRow(index: index, receipt: receipt)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
            .accessibilityElement(children: .contain)
            .accessibilityLabel(spokenStepsSummaryLabel())
        }
    }

    @ViewBuilder
    func stepRow(index: Int, receipt: AtlasCodeHealStepReceipt) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: receipt.status == "completed" ? "checkmark" : "xmark")
                .atlasSans(10, .semibold)
                .foregroundStyle(receipt.status == "completed" ? AtlasCodePalette.healed : AtlasCodePalette.alert)
                .padding(.top, 2)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(receipt.action)
                    .atlasSans(12)
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
                if !receipt.result.isEmpty {
                    Text(receipt.result)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenStepLabel(receipt))
        .accessibilityIdentifier(A11yID.codeHealStep(index))
    }

    @ViewBuilder
    var undoErrorLine: some View {
        if let err = undoError, !err.isEmpty {
            Text(err)
                .font(AtlasFont.serif(14))
                .foregroundStyle(AtlasCodePalette.alert)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier(A11yID.codeHealUndoError)
                .accessibilityLabel(AtlasCodeHealVetoJudgment.spokenUndoError(err))
        }
    }

    @ViewBuilder
    var receiptUndoFooter: some View {
        if let note = AtlasCodeUndoWindow.note(expiresAt: undoExpiresAt) {
            Text(note)
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityIdentifier(A11yID.codeHealUndoWindow)
                .accessibilityLabel(spokenUndoWindowLabel(note))
        }
        if canUndo {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                // WAVE-048: do not dismiss before result — undoError must be visible.
                onUndo()
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "arrow.uturn.backward")
                        .accessibilityHidden(true)
                    Text(AtlasCodeProvenanceJudgment.productUndoWithReceipt)
                }
                .atlasSans(15, .medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(AtlasTheme.textSecondary)
                .atlasCard(cornerRadius: 13)
            }
            .buttonStyle(PressableScale())
            .transition(reduceMotion ? .identity : .opacity)
            .accessibilityIdentifier(A11yID.codeHealUndo)
            .accessibilityLabel(spokenUndoButtonLabel())
            .accessibilityHint(spokenUndoButtonHint())
        }
    }

    // MARK: - Spoken

    func spokenSheetLabel() -> String {
        AtlasCodeHealVetoJudgment.spokenSheet(heal: heal, undoError: undoError)
    }

    func spokenMastheadLabel() -> String {
        hasCompletedHeal
            ? "curado sozinho, modo \(heal.mode)"
            : "cura, modo \(heal.mode)"
    }

    func spokenSilenceLabel() -> String {
        "você não foi necessário, cura concluída sem portão"
    }

    func spokenBlockedLabel(_ blocked: String) -> String {
        "cura bloqueada, \(blocked)"
    }

    func spokenEmptyStepsLabel() -> String {
        "recibo sem passos registrados pelo servidor"
    }

    func spokenStepLabel(_ receipt: AtlasCodeHealStepReceipt) -> String {
        let outcome = receipt.status == "completed" ? "concluído" : "falhou"
        var parts = ["passo \(receipt.step)", receipt.action, outcome]
        if !receipt.result.isEmpty { parts.append(receipt.result) }
        return parts.joined(separator: ", ")
    }

    func spokenUndoWindowLabel(_ note: String) -> String {
        "janela de veto, \(note)"
    }

    func spokenStepsSummaryLabel() -> String {
        "\(heal.stepReceipts.count) passo\(heal.stepReceipts.count == 1 ? "" : "s") no recibo"
    }

    func spokenUndoButtonLabel() -> String {
        canUndo ? "desfazer cura com recibo" : "desfazer indisponível"
    }

    func spokenUndoButtonHint() -> String {
        canUndo
            ? "envia veto retroativo auditável para esta cura"
            : "prazo de veto encerrado ou recibo sem identificador"
    }
}

// MARK: - AtlasCodeWhySheet

// MARK: - Sheet

struct AtlasCodeWhySheet: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var model: AtlasCodeWhyModel
    let repo: String
    let file: String

    init(client: AtlasClient, repo: String, file: String) {
        _model = State(initialValue: AtlasCodeWhyModel(client: client))
        self.repo = repo
        self.file = file
    }

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    content
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(22)
                .animation(reduceMotion ? nil : AtlasMotion.editorial, value: whyContentPhaseID)
            }
            .scrollIndicators(.hidden)
        }
        .task { if model.phase == .idle { await model.load(repo: repo, file: file) } }
        .accessibilityIdentifier(A11yID.whySheet)
        .accessibilityLabel(whySheetSpokenLabel)
        .accessibilityHint(Self.spokenSheetHint)
    }

    // MARK: - Header

    var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(AtlasCodeProvenanceJudgment.productWhyFileKicker)
                .atlasSans(10, .semibold)
                .tracking(1.5)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(file)
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(2)
                .truncationMode(.middle)
                .accessibilityHidden(true)
            // WAVE-056: truncation banner from Judgment (published counts only).
            if let why = model.why, let banner = AtlasCodeWhyJudgment.truncatedBanner(why) {
                Text(banner)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(whyHeaderSpokenLabel)
    }

    // MARK: - Content

    @ViewBuilder var content: some View {
        switch model.phase {
        case .idle, .loading:
            HStack(spacing: 10) {
                BreathingDiamond(size: 10, reduceMotion: reduceMotion)
                    .accessibilityHidden(true)
                Text(AtlasCodeProvenanceJudgment.productReadingFileHistory)
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(.top, 8)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenLoading())
        case .failed:
            VStack(alignment: .leading, spacing: 6) {
                Text(AtlasCodeProvenanceJudgment.productBiographyUnavailable)
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .accessibilityHidden(true)
                if let message = model.message, !message.isEmpty {
                    Text(message)
                        .font(AtlasFont.mono(9.5))
                        .foregroundStyle(AtlasCodePalette.alert)
                        .accessibilityHidden(true)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenFailed())
        case .loaded:
            if let why = model.why {
                if why.commits.isEmpty {
                    Text(AtlasCodeProvenanceJudgment.productNoFileHistory)
                        .font(AtlasFont.serifItalic(16))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .padding(.top, 6)
                        .accessibilityLabel(spokenEmptyHistory())
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(why.commits.enumerated()), id: \.element.id) { index, commit in
                            whyRow(commit, index: index, isLast: index == why.commits.count - 1)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Rows

    func whyRow(_ commit: AtlasCodeWhy.Commit, index: Int, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Circle()
                    .fill(AtlasTheme.accent)
                    .frame(width: 7, height: 7)
                    .accessibilityHidden(true)
                if !isLast {
                    Rectangle()
                        .fill(AtlasTheme.accent.opacity(0.35))
                        .frame(width: 1)
                        .frame(minHeight: 56)
                        .accessibilityHidden(true)
                }
            }
            .padding(.top, 8)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                if let quote = commit.provenance?.quote {
                    Text("\u{201C}\(quote)\u{201D}")
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityHidden(true)
                } else {
                    Text(AtlasCodeProvenanceJudgment.productNoProvenanceRecorded)
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
                Text(meta(for: commit))
                    .font(AtlasFont.mono(10.5))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                Text(commit.subject)
                    .atlasSans(12)
                    .foregroundStyle(AtlasTheme.textSecondary.opacity(0.75))
                    .lineLimit(2)
                    .accessibilityHidden(true)
            }
            .padding(.bottom, isLast ? 0 : 18)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenCommit(commit))
        .accessibilityIdentifier(A11yID.whyRow(index))
    }

    func meta(for commit: AtlasCodeWhy.Commit) -> String {
        var parts = [commit.agentLabel]
        if let when = commit.when {
            parts.append("há \(AtlasCodeRelativeTime.short(from: Int(when.timeIntervalSince1970)))")
        }
        parts.append(commit.shortHash)
        if let obra = commit.provenance?.obra, !obra.isEmpty { parts.append(obra) }
        return parts.joined(separator: " · ")
    }

    // MARK: - A11y (WAVE-056: Judgment face)

    var whyFace: AtlasCodeWhyFace {
        AtlasCodeWhyJudgment.face(model: model)
    }

    var whyContentPhaseID: String {
        AtlasCodeWhyJudgment.contentPhaseID(face: whyFace)
    }

    var whyHeaderSpokenLabel: String {
        AtlasCodeWhyJudgment.spokenHeader(file: file, face: whyFace)
    }

    var whySheetSpokenLabel: String {
        AtlasCodeWhyJudgment.spokenSheet(file: file, face: whyFace)
    }

    func spokenLoading() -> String {
        AtlasCodeWhyFace.loading.spokenFace
    }

    func spokenFailed() -> String {
        AtlasCodeWhyJudgment.face(
            phase: .failed(""),
            why: nil,
            message: model.message
        ).spokenFace
    }

    func spokenEmptyHistory() -> String {
        AtlasCodeWhyFace.empty.spokenFace
    }

    func spokenCommit(_ commit: AtlasCodeWhy.Commit) -> String {
        var parts: [String] = []
        if let quote = commit.provenance?.quote, !quote.isEmpty {
            parts.append(quote)
        } else {
            parts.append("sem proveniência registrada")
        }
        parts.append(commit.agentLabel)
        if let when = commit.when {
            parts.append("há \(AtlasCodeRelativeTime.short(from: Int(when.timeIntervalSince1970)))")
        }
        parts.append(commit.shortHash)
        if let obra = commit.provenance?.obra, !obra.isEmpty { parts.append(obra) }
        if !commit.subject.isEmpty { parts.append(commit.subject) }
        return parts.joined(separator: ", ")
    }

    static let spokenSheetHint = "histórico de commits e proveniência registrada pelo Atlas"
}

// MARK: - Model

@MainActor
@Observable
final class AtlasCodeWhyModel {
    private let client: AtlasClient
    private(set) var phase: LoadPhase = .idle
    private(set) var why: AtlasCodeWhy?
    private(set) var message: String?
    private var wanted: String?

    init(client: AtlasClient) {
        self.client = client
    }

    func load(repo: String, file: String) async {
        let key = "\(repo)\n\(file)"
        wanted = key
        phase = .loading
        message = nil
        do {
            let response = try await client.getCodeWhy(repo: repo, file: file)
            guard wanted == key else { return }
            why = response
            phase = .loaded
        } catch {
            guard wanted == key else { return }
            message = String(describing: error)
            phase = .failed(message ?? "falha desconhecida")
        }
    }
}

// MARK: - Judgment

// MARK: - Types

/// Exclusive file-biography (H1 Why) face (WAVE-056).
enum AtlasCodeWhyFace: Equatable {
    case loading
    case failed(String?)
    case empty
    case timeline(Int)
    case truncated(shown: Int, total: Int)

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .failed: return "failed"
        case .empty: return "empty"
        case .timeline: return "timeline"
        case .truncated: return "truncated"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading:
            return "lendo a história do arquivo"
        case .failed(let message):
            if let message, !message.isEmpty {
                return "biografia indisponível, \(message)"
            }
            return "biografia indisponível"
        case .empty:
            return "este arquivo não tem história neste recorte"
        case .timeline(let n):
            return n == 1
                ? "1 commit na biografia do arquivo"
                : "\(n) commits na biografia do arquivo"
        case .truncated(let shown, let total):
            return "mostrando \(shown) de \(total) commits, história truncada"
        }
    }
}

// MARK: - Judgment

/// Pure Why biography grammar — face · spoken · pack.
enum AtlasCodeWhyJudgment {

    static func face(
        phase: LoadPhase,
        why: AtlasCodeWhy?,
        message: String?
    ) -> AtlasCodeWhyFace {
        switch phase {
        case .idle, .loading:
            return .loading
        case .failed:
            return .failed(message)
        case .loaded:
            guard let why else { return .empty }
            if why.commits.isEmpty { return .empty }
            if why.truncated {
                return .truncated(shown: why.commits.count, total: why.commitsTotal)
            }
            return .timeline(why.commits.count)
        }
    }

    /// Convenience when model is available on MainActor.
    @MainActor
    static func face(model: AtlasCodeWhyModel) -> AtlasCodeWhyFace {
        face(phase: model.phase, why: model.why, message: model.message)
    }

    static func truncatedBanner(_ why: AtlasCodeWhy) -> String? {
        guard why.truncated else { return nil }
        return "mostrando \(why.commits.count) de \(why.commitsTotal) · história truncada"
    }

    static func spokenSheet(file: String, face: AtlasCodeWhyFace) -> String {
        "biografia do arquivo \(file), \(face.spokenFace)"
    }

    static func spokenHeader(file: String, face: AtlasCodeWhyFace) -> String {
        switch face {
        case .truncated(let shown, let total):
            return "\(file), mostrando \(shown) de \(total)"
        default:
            return file
        }
    }

    static func contentPhaseID(face: AtlasCodeWhyFace) -> String {
        switch face {
        case .loading: return "loading"
        case .failed: return "failed"
        case .empty: return "empty"
        case .timeline(let n): return "timeline-\(n)"
        case .truncated(let shown, let total): return "truncated-\(shown)-\(total)"
        }
    }

    static func packFacts(
        file: String,
        phase: LoadPhase,
        why: AtlasCodeWhy?,
        message: String?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(phase: phase, why: why, message: message)
        facts.append("why_face: \(face.productWord)")
        facts.append("why_file: \(file)")
        switch face {
        case .loading:
            absences.append("biografia ainda carregando")
        case .failed(let msg):
            absences.append("biografia falhou")
            if let msg, !msg.isEmpty { facts.append("why_error: \(msg)") }
        case .empty:
            absences.append("sem commits na biografia deste recorte")
        case .timeline(let n):
            facts.append("why_commits: \(n)")
        case .truncated(let shown, let total):
            facts.append("why_commits_shown: \(shown)")
            facts.append("why_commits_total: \(total)")
            facts.append("why_truncated: true")
        }
        return (facts, absences)
    }
}

// MARK: - AtlasCodeAskContext

// MARK: - Context

// MARK: - Host

enum AtlasCodeAskContext {
    static let productInvite = "pergunte sobre este repositório"

    static var emptySuggestions: [String] { AtlasCodeAskSuggestions.all }

    static func productEmptyPrompt(focusLegend: String?) -> String {
        if let focusLegend, !focusLegend.isEmpty {
            return "sobre \(focusLegend) — o que você quer saber?"
        }
        return productInvite
    }

    @MainActor
    static func facts(
        model: AtlasCodeModel,
        focusNode: AtlasCodeGraphNode?,
        focusLegend: String?,
        isAnchoring: Bool,
        graphStateFilter: AtlasCodeGraphStateFilter = .all,
        serverAskFacts: String? = nil,
        provenancePhase: AtlasCodeProvenanceModel.Phase = .idle,
        whyFile: String? = nil,
        whyPhase: LoadPhase = .idle,
        why: AtlasCodeWhy? = nil,
        whyMessage: String? = nil
    ) -> String {
        occasionFacts(
            model: model,
            focusNode: focusNode,
            focusLegend: focusLegend,
            isAnchoring: isAnchoring,
            graphStateFilter: graphStateFilter,
            serverAskFacts: serverAskFacts,
            provenancePhase: provenancePhase,
            whyFile: whyFile,
            whyPhase: whyPhase,
            why: why,
            whyMessage: whyMessage
        )
    }

    @MainActor
    static func occasionFacts(
        model: AtlasCodeModel,
        focusNode: AtlasCodeGraphNode?,
        focusLegend: String?,
        isAnchoring: Bool,
        graphStateFilter: AtlasCodeGraphStateFilter,
        serverAskFacts: String?,
        provenancePhase: AtlasCodeProvenanceModel.Phase = .idle,
        whyFile: String? = nil,
        whyPhase: LoadPhase = .idle,
        why: AtlasCodeWhy? = nil,
        whyMessage: String? = nil
    ) -> String {
        var anchors: [String] = []
        var facts: [String] = ["repo: \(model.repo)"]
        var absences: [String] = []

        if let legend = focusLegend?.trimmingCharacters(in: .whitespacesAndNewlines), !legend.isEmpty {
            anchors.append("legend: \(legend)")
        }
        if let node = focusNode {
            let short = String(node.hash.prefix(7))
            anchors.append("commit: \(short)")
            if let message = node.message, !message.isEmpty {
                anchors.append("subject: \(message)")
            }
            let state = model.state(for: node)
            anchors.append("state: \(AtlasCodeGraphJudgment.productWord(for: state))")
            // WAVE-167: commit row + provenance organs for focused node.
            let rowPack = AtlasCodeCommitRowJudgment.packFacts(
                node: node,
                state: state,
                isDimmed: false,
                trunk: model.graph?.defaultBranch,
                ruleId: nil
            )
            facts.append(contentsOf: rowPack.facts)
            absences.append(contentsOf: rowPack.absences)
            let provPack = AtlasCodeProvenanceJudgment.packFacts(
                node: node,
                state: state,
                trunk: model.graph?.defaultBranch,
                phase: provenancePhase,
                ruleId: nil
            )
            facts.append(contentsOf: provPack.facts)
            absences.append(contentsOf: provPack.absences)
        } else if isAnchoring {
            anchors.append("âncora H6 ativa (sem nó de swipe local)")
        }

        // WAVE-167: why/biography organ when sheet target published.
        if let whyFile, !whyFile.isEmpty {
            let whyPack = AtlasCodeWhyJudgment.packFacts(
                file: whyFile,
                phase: whyPhase,
                why: why,
                message: whyMessage
            )
            facts.append(contentsOf: whyPack.facts)
            absences.append(contentsOf: whyPack.absences)
        }

        // WAVE-161: graph screen face organ (loading/failed/empty/ready).
        let failMsg: String? = {
            if case .failed(let m) = model.phase { return m }
            return nil
        }()
        let screenPack = AtlasCodeGraphLoadJudgment.packFacts(
            repo: model.repo,
            phase: model.phase,
            nodeCount: model.graph?.nodes.count ?? 0,
            failMessage: failMsg,
            isAnchoring: isAnchoring
        )
        facts.append(contentsOf: screenPack.facts)
        absences.append(contentsOf: screenPack.absences)

        // WAVE-062: exclusive ask-pill face (invite / anchoring / legend).
        let pill = AtlasCodeAskPillJudgment.packFacts(
            isAnchoring: isAnchoring,
            anchorLegend: focusLegend
        )
        facts.append(contentsOf: pill.facts)
        absences.append(contentsOf: pill.absences)

        // WAVE-187: graph identity (trunk/head/commits/phase).
        let identity = AtlasCodeGraphJudgment.packIdentityFacts(model: model)
        facts.append(contentsOf: identity.facts)
        absences.append(contentsOf: identity.absences)

        // WAVE-028: filter · status · worktrees · slice (same fatia as chips/list).
        let slice = AtlasCodeGraphJudgment.packSliceFacts(model: model, filter: graphStateFilter)
        facts.append(contentsOf: slice.facts)
        absences.append(contentsOf: slice.absences)

        // WAVE-043: exclusive repo health face (scan · heal · week · mirror when host passes).
        let health = AtlasCodeRepoHealthJudgment.packFacts(model: model, mirror: nil)
        facts.append(contentsOf: health.facts)
        absences.append(contentsOf: health.absences)

        // WAVE-048: heal veto face + undo failure honesty.
        let veto = AtlasCodeHealVetoJudgment.packFacts(
            heal: model.heal,
            undoError: model.undoError
        )
        facts.append(contentsOf: veto.facts)
        absences.append(contentsOf: veto.absences)

        absences.append("dual-count obra/branch vs issues não reconciliado na casca (Core §5 se faltar DTO)")
        absences.append("filtro por agente não exposto no pack (sem DTO de filter)")
        absences.append(contentsOf: AtlasCodeGraphJudgment.packCanDoAbsences(hasHealReceipt: model.hasHealReceipt))

        let healthFace = AtlasCodeRepoHealthJudgment.face(model: model, mirror: nil)
        let subject = "repositório \(model.repo) · \(slice.subjectSuffix) · \(healthFace.productWord)"

        return AgenticOccasionPack(
            surface: "code.graph",
            subject: subject,
            anchors: anchors,
            facts: facts,
            absences: absences,
            canDo: AtlasCodeGraphJudgment.packCanDo(hasHealReceipt: model.hasHealReceipt),
            appendix: serverAskFacts
        ).render()
    }
}

// MARK: - Model

@Observable
@MainActor
final class AtlasCodeAskModel {
    enum Phase: Equatable {
        case idle
        case answered(AtlasCodeAskResponse)
    }

    let client: AtlasClient
    private(set) var repo: String
    private(set) var phase: Phase = .idle
    /// Legenda de âncora de swipe/proveniência — mesma voz da pílula e do emptyPrompt.
    /// Presentation-only; não é âncora de resposta git (`anchors` / `anchorNote`).
    private(set) var sheetFocusLegend: String?

    init(client: AtlasClient, repo: String) {
        self.client = client
        self.repo = repo
    }

    func adoptRepo(_ newRepo: String) {
        guard newRepo != repo else { return }
        repo = newRepo
        phase = .idle
        sheetFocusLegend = nil
    }

    func setSheetFocusLegend(_ legend: String?) {
        let trimmed = legend?.trimmingCharacters(in: .whitespacesAndNewlines)
        sheetFocusLegend = (trimmed?.isEmpty == false) ? trimmed : nil
    }

    /// Os commits que a resposta atual cita. O grafo acende só estes.
    var anchors: Set<String> {
        if case .answered(let response) = phase { return response.anchorSet }
        return []
    }

    /// Verdadeiro quando há resposta apontando para commits: o grafo então
    /// apaga o resto, porque a resposta é o assunto.
    var isAnchoring: Bool { !anchors.isEmpty }

    /// A legenda do recorte: "12 de 43 acesos no grafo".
    ///
    /// Um mapa com 3/4 da história a 0.26 de opacidade e nenhuma frase dizendo
    /// o porquê lê como "é só isso" — que é mentira sobre o repositório. O
    /// servidor calcula `commits_total` e `truncated` exatamente para esta
    /// frase existir, e ela estava escrita e morta: `anchorNote` não tinha um
    /// único chamador no app inteiro. Contrato dos dois lados, faltando o Text.
    var anchorNote: String? {
        if case .answered(let response) = phase { return response.anchorNote }
        return nil
    }

    /// Limpar apaga a âncora de resposta: o grafo volta a mostrar tudo.
    /// Não mexe em `sheetFocusLegend` (swipe) — use `setSheetFocusLegend(nil)`.
    func clear() {
        phase = .idle
    }

    /// Os fatos de um turno da conversa, para o agente ler antes de responder.
    ///
    /// Efeito colateral deliberado: a mesma leitura ancora o grafo. Quando o
    /// card fecha, o mapa atrás já está aceso nos commits que sustentaram a
    /// resposta — perguntar move a topologia, que é o ponto da tela.
    ///
    /// `nil` quando o determinístico não sabe (julgamento não é filtro de git) e
    /// quando a rede cai: o agente responde sem muleta, e falha de rede nunca
    /// vira fato inventado com ar de autoridade.
    ///
    /// `answered` é o que decide se a topologia se move, e a distinção é fina:
    /// - `answered == false` → o git NÃO foi lido (julgamento, ou git mudo).
    ///   A leitura não tem opinião sobre o mapa, então o mapa fica como está.
    ///   Sem esta guarda, "explica melhor" — a coisa mais natural do mundo num
    ///   card de conversa — apagava em silêncio a resposta anterior, e a tese
    ///   da tela sobrevivia a exatamente um turno.
    /// - `answered == true` com zero commits → o git FOI lido e não há o que
    ///   acender ("nada mudou hoje"). Aí a âncora morre mesmo: a leitura nova é
    ///   a verdade nova, e segurar o mapa velho seria mentir com mapa.
    ///
    /// É a mesma guarda de `AtlasCodeFacts.block`: quem não leu não afirma.
    func facts(for question: String) async -> String? {
        guard let response = try? await client.askCode(repo: repo, question: question, mode: .facts),
              response.answered
        else { return nil }
        phase = .answered(response)
        return AtlasCodeFacts.block(from: response)
    }
}
