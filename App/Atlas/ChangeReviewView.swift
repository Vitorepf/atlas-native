import AtlasCore
import SwiftUI
import Foundation
import Observation

// Cycle 044 fuse → ChangeReviewView.swift

// C15 — Revisar mudanças de uma execução (o "Review" da cena 12, real).
// Conteúdo: ChangeReviewView+Content · spoken: +A11y · available: +Available.
struct ChangeReviewSheet: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var expandedDiffPatch: String?
    @State var applying = false
    @State var loadFinished = false

    var review: AtlasTraceChangeReview? { reviews.changeReviewsByTrace[traceId] }

    var body: some View {
        reviewSheetChrome
            .task { await refreshReviewTask() }
    }
}

extension ChangeReviewAvailableContent {
    @ViewBuilder
    var reviewSectionsAfterPatches: some View {
        if !review.controls.isEmpty { ChangeReviewControlsSection(controls: review.controls) }
        if !review.testRuns.isEmpty { ChangeReviewTestsSection(tests: review.testRuns) }
        if !review.review.findings.isEmpty { ChangeReviewFindingsSection(findings: review.review.findings) }
        if !review.review.operatorActions.isEmpty {
            ChangeReviewDecidedSection(actions: review.review.operatorActions)
        }
        ChangeReviewRunActions(
            review: review,
            reviews: reviews,
            traceId: traceId,
            applying: $applying
        )
    }
}

extension ChangeReviewSheet {
    @ViewBuilder
    func reviewAvailableContent(_ review: AtlasTraceChangeReview) -> some View {
        switch review.state {
        case .unavailable:
            reviewUnavailableContent(review)
        case .available:
            reviewAvailableBranch(review)
        }
    }
}

extension ChangeReviewSheet {
    @ViewBuilder
    func reviewAvailableBranch(_ review: AtlasTraceChangeReview) -> some View {
        if Self.hasReviewSurface(review) {
            ChangeReviewAvailableContent(
                reviews: reviews,
                traceId: traceId,
                review: review,
                expandedDiffPatch: $expandedDiffPatch,
                applying: $applying
            )
        } else {
            reviewEmptySurface()
        }
    }
}

// de Sections a estendem; a definição não chegou ao merge).

struct ChangeReviewAvailableContent: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let review: AtlasTraceChangeReview
    @Binding var expandedDiffPatch: String?
    @Binding var applying: Bool

    var body: some View {
        reviewSections
    }
}

extension ChangeReviewSheet {
    func reviewUnavailableContent(_ review: AtlasTraceChangeReview) -> some View {
        TraceEvidenceUnavailable(
            title: "Sem revisão de mudanças nesta execução.",
            subtitle: TraceEvidenceCopy.unavailableReason(review.reason),
            identifier: A11yID.reviewUnavailable,
            spoken: TraceEvidenceCopy.unavailableSpoken(
                prefix: "sem revisão de mudanças nesta execução",
                reason: review.reason
            ),
            systemImage: "doc.text.magnifyingglass"
        )
    }
}

extension ChangeReviewSheet {
    func reviewEmptySurface() -> some View {
        TraceEvidenceUnavailable(
            title: "Revisão ligada, mas sem patches nem provas publicadas.",
            subtitle: "o servidor confirmou o vínculo, porém não há diff, checks ou achados a mostrar.",
            identifier: A11yID.reviewEmpty,
            spoken: "revisão ligada mas sem patches nem provas publicadas",
            systemImage: "doc.text.magnifyingglass"
        )
    }
}

extension ChangeReviewSheet {
    var reviewSheetChrome: some View {
        NavigationStack {
            // Fundo como .background: destrava o scroll-edge material da barra.
            content
                .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                reviewToolbar
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 4) {
                        Text("Revisar mudanças")
                            .font(AtlasFont.serif(17, .semibold))
                            .foregroundStyle(AtlasTheme.textPrimary)
                        AtlasGoldTitleRule(width: 56, peak: 0.5)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel("Revisar mudanças")
                }
            }
            .overlay(alignment: .top) { ChangeReviewToast(reviews: reviews, reduceMotion: reduceMotion) }
            .accessibilityIdentifier(A11yID.reviewSheet)
            // Contain without fused sheet label so patches/actions stay focusable.
            .accessibilityElement(children: .contain)
        }
    }
}

extension ChangeReviewSheet {
    @ViewBuilder
    var content: some View {
        if review == nil {
            reviewUnavailableContent
        } else if let review {
            reviewAvailableContent(review)
        }
    }
}

extension ChangeReviewSheet {
    func refreshReviewTask() async {
        await reviews.refreshChangeReview(traceId: traceId)
        loadFinished = true
    }
}

extension ChangeReviewAvailableContent {
    @ViewBuilder
    var reviewSections: some View {
        if let run = review.run { ChangeReviewRunHeader(run: run) }
        ChangeReviewGovernanceSection(reviews: reviews, traceId: traceId)
        reviewPatchTail
    }
}

extension ChangeReviewAvailableContent {
    @ViewBuilder
    var reviewPatchTail: some View {
        ForEach(review.patches) { patch in
            ChangeReviewPatchCard(
                reviews: reviews,
                traceId: traceId,
                patch: patch,
                expandedDiffPatch: $expandedDiffPatch
            )
        }
        reviewSectionsAfterPatches
    }
}

extension ChangeReviewSheet {
    /// Patches, checks, testes ou achados — nunca UI vazia fingindo conteúdo.
    static func hasReviewSurface(_ review: AtlasTraceChangeReview) -> Bool {
        !review.patches.isEmpty
            || !review.controls.isEmpty
            || !review.testRuns.isEmpty
            || !review.review.findings.isEmpty
            || !review.review.operatorActions.isEmpty
            || !review.review.availableActions.isEmpty
    }
}

extension ChangeReviewSheet {
    var reviewToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            AtlasCloseToolbarButton(
                spokenLabel: "fechar revisão de mudanças",
                spokenHint: "volta para a conversa",
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
    }
}

extension ChangeReviewSheet {
    @ViewBuilder
    var reviewUnavailableContent: some View {
        if !loadFinished, review == nil {
            TraceEvidenceLoading(text: "consultando a revisão…", reduceMotion: reduceMotion)
        } else if loadFinished, review == nil {
            TraceEvidenceUnavailable(
                title: "Não foi possível consultar a revisão.",
                subtitle: "feche e tente de novo — o motivo pode estar no aviso superior.",
                identifier: A11yID.reviewLoadFailure,
                spoken: "não foi possível consultar a revisão",
                systemImage: "doc.text.magnifyingglass"
            )
        }
    }
}


// Cycle 043 fuse → ChangeReviewRunActions.swift

/// Aceitar o run = aceitar todos os arquivos capturados e depois o run —
/// semântica do servidor; o botão só existe se a ação estiver disponível.
struct ChangeReviewRunActions: View {
    let review: AtlasTraceChangeReview
    let reviews: ChangeReviewModel
    let traceId: TraceID
    @Binding var applying: Bool
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        let available = review.review.availableActions
        if !available.isEmpty {
            runActionButtonRow(available: available)
            .disabled(applying)
            .padding(.top, 4)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: applying)
        }
    }
}

extension ChangeReviewRunActions {
    var acceptButtonLabel: some View {
        Text("Aceitar tudo")
            .font(AtlasFont.serif(14, .semibold)).foregroundStyle(AtlasTheme.bg)
            .padding(.horizontal, 18).padding(.vertical, 11)
            .frame(minHeight: 48)
            .background(Capsule().fill(AtlasTheme.accent))
            .atlasElevation(radius: 10, y: 3, opacity: 0.2)
            .contentShape(Capsule())
    }
}

extension ChangeReviewRunActions {
    @ViewBuilder
    var applyingIndicator: some View {
        if reduceMotion {
            applyingStaticLabel
        } else {
            ProgressView()
                .tint(AtlasTheme.accent)
                .accessibilityLabel("Registrando decisão")
        }
    }
}

extension ChangeReviewRunActions {
    var applyingStaticLabel: some View {
        Text("Registrando…")
            .font(AtlasFont.mono(10))
            // Soft gold-quiet applying meta.
            .foregroundStyle(AtlasTheme.accent.opacity(0.62))
            .accessibilityLabel("Registrando decisão")
    }
}

extension ChangeReviewRunActions {
    @ViewBuilder
    func runActionButtonRow(available: [AtlasTraceChangeReview.Action]) -> some View {
        HStack(spacing: 10) {
            acceptButton(available: available)
            rejectButton(available: available)
            if applying { applyingIndicator }
        }
    }
}

extension ChangeReviewRunActions {
    func performAccept() {
        // Medium: accept-all is primary governed commit.
        AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
        applying = true
        Task { await reviews.applyChangeReview(traceId: traceId, action: .accept); applying = false }
    }
}

extension ChangeReviewRunActions {
    @ViewBuilder
    func acceptButton(available: [AtlasTraceChangeReview.Action]) -> some View {
        if available.contains(.accept) {
            Button(action: performAccept) {
                acceptButtonLabel
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("Aceitar todos os arquivos e concluir revisão")
            .accessibilityHint("Aceita cada arquivo capturado e depois conclui o run")
            .accessibilityAddTraits(.isButton)
            .accessibilitySortPriority(9)
            .accessibilityIdentifier(A11yID.reviewRunAccept)
        }
    }
}

extension ChangeReviewRunActions {
    func rejectReviewAction() {
        applying = true
        Task { await reviews.applyChangeReview(traceId: traceId, action: .reject); applying = false }
    }
}

extension ChangeReviewRunActions {
    @ViewBuilder
    func rejectButton(available: [AtlasTraceChangeReview.Action]) -> some View {
        if available.contains(.reject) {
            Button {
                // Medium: reject-all is primary governed commit (destructive).
                AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
                rejectReviewAction()
            } label: {
                rejectButtonLabel
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("Rejeitar revisão inteira")
            .accessibilityHint("Rejeita o run de engenharia desta execução")
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier(A11yID.reviewRunReject)
        }
    }
}

extension ChangeReviewRunActions {
    var rejectButtonLabel: some View {
        Text("Rejeitar")
            .font(AtlasFont.serif(14, .semibold)).foregroundStyle(AtlasTheme.domOperacional)
            .padding(.horizontal, 18).padding(.vertical, 11)
            .frame(minHeight: 48)
            .background(Capsule().fill(AtlasTheme.domOperacional.opacity(0.1)))
            .overlay(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.45), lineWidth: 1))
            .atlasElevation(radius: 8, y: 2, opacity: 0.12)
            .contentShape(Capsule())
    }
}


// Cycle 044 fuse → ChangeReviewCouncilSection.swift

// MARK: - Governance / Conselho (C18 · C19 · C21)

/// C18 · C19 · C21 — as provas que o servidor emite. Cada bloco só existe
/// se a fonte existir: sem diff medido, sem replanejamento e sem conselho,
/// esta seção inteira desaparece (estado por exceção).
struct ChangeReviewGovernanceSection: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        if let trace = reviews.governanceByTrace[traceId] {
            let stats = AtlasTraceGovernance.diffStats(from: trace.metadata)
            let revisions = AtlasTraceGovernance.planRevisions(from: trace.metadata)
            let council = AtlasTraceGovernance.councilReview(from: trace.metadata)
            governanceContent(stats: stats, revisions: revisions, council: council)
        }
    }
}

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func councilBlock(_ council: [AtlasTraceGovernance.CouncilMember]) -> some View {
        let diverged = AtlasTraceGovernance.councilDiverged(council)
        VStack(alignment: .leading, spacing: 6) {
            councilBlockHeader(diverged: diverged)
            ForEach(council) { member in
                ChangeReviewCouncilMemberRow(member: member)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }
        }
        // Contain without fused label: council member rows stay focusable.
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.reviewCouncil)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: council.map(\.id))
    }
}

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func governanceContentStack(
        stats: AtlasTraceGovernance.DiffStats?,
        revisions: [AtlasTraceGovernance.PlanRevision],
        council: [AtlasTraceGovernance.CouncilMember]
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let stats {
                governanceStatsLine(stats)
            }
            governanceRevisionsLine(revisions)
            governanceCouncilBlock(council)
        }
    }
}

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func governanceContent(
        stats: AtlasTraceGovernance.DiffStats?,
        revisions: [AtlasTraceGovernance.PlanRevision],
        council: [AtlasTraceGovernance.CouncilMember]
    ) -> some View {
        if stats != nil || !revisions.isEmpty || !council.isEmpty {
            governanceChrome {
                governanceContentStack(
                    stats: stats,
                    revisions: revisions,
                    council: council
                )
            }
        }
    }
}

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func councilBlockHeader(diverged: Bool) -> some View {
        HStack(spacing: 8) {
            Text("Conselho")
                .atlasSans(11, .semibold)
                // Soft gold-quiet review section header.
                .foregroundStyle(AtlasTheme.accent.opacity(0.72))
                .accessibilityAddTraits(.isHeader)
            if diverged {
                Text("Divergência")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityLabel("Divergência entre pareceres")
            }
        }
    }
}

extension ChangeReviewGovernanceSection {
    func governanceChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AtlasTheme.surface.opacity(0.45), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
            .accessibilityIdentifier(A11yID.reviewGovernance)
    }
}

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func governanceCouncilBlock(_ council: [AtlasTraceGovernance.CouncilMember]) -> some View {
        if !council.isEmpty {
            councilBlock(council)
        }
    }
}

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func governanceRevisionsLine(_ revisions: [AtlasTraceGovernance.PlanRevision]) -> some View {
        if let last = revisions.last {
            HStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                    .atlasSans(11)
                    // Soft gold-quiet meta glyph — governance chrome.
                    .foregroundStyle(AtlasTheme.accent.opacity(0.55))
                    .accessibilityHidden(true)
                Text(revisions.count == 1
                     ? "plano v1 arquivado — \(last.humanReason)"
                     : "\(revisions.count) versões de plano arquivadas — \(last.humanReason)")
                    .atlasSans(12)
                    // Soft gold-quiet governance revision line.
                    .foregroundStyle(AtlasTheme.accent.opacity(0.72))
            }
        }
    }
}

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func governanceStatsLine(_ stats: AtlasTraceGovernance.DiffStats) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "plusminus")
                .atlasSans(11)
                // Soft gold-quiet meta glyph — governance chrome.
                .foregroundStyle(AtlasTheme.accent.opacity(0.55))
                .accessibilityHidden(true)
            Text(stats.headline)
                .font(AtlasFont.mono(11))
                // Soft gold-quiet governance stats headline.
                .foregroundStyle(AtlasTheme.accent.opacity(0.72))
                .accessibilityLabel("\(stats.filesTouched) arquivos, mais \(stats.linesAdded), menos \(stats.linesRemoved) linhas")
        }
    }
}


// Cycle 043 fuse → ChangeReviewCouncilRow.swift

struct ChangeReviewCouncilMemberRow: View {
    let member: AtlasTraceGovernance.CouncilMember

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            providerHeader
            metaRow
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(member.spokenCouncilLine)
        .accessibilityIdentifier(A11yID.reviewCouncilMember(member.provider))
    }
}

/// Só fala o que `council_review` publica; sem `agentVerdicts` nem papéis inventados.

extension AtlasTraceGovernance.CouncilMember {
    var spokenCouncilLine: String {
        var parts = [provider]
        if let model = model { parts.append(model) }
        parts.append("status \(status)")
        if let hash = responseHash {
            parts.append("hash de resposta \(String(hash.prefix(12)))")
        }
        if let code = errorCode { parts.append("código \(code)") }
        if let latency = latencyMs { parts.append("\(latency) milissegundos") }
        return parts.joined(separator: ", ")
    }
}

extension ChangeReviewCouncilMemberRow {
    var providerOutcomeGlyph: some View {
        Image(systemName: member.succeeded ? "checkmark" : "xmark")
            .atlasSans(9, .semibold)
            .foregroundStyle(member.succeeded ? AtlasCodePalette.healed : AtlasTheme.alert)
            .accessibilityHidden(true)
    }
}

extension ChangeReviewCouncilMemberRow {
    var providerHeader: some View {
        HStack(spacing: 7) {
            providerOutcomeGlyph
            Text(member.provider)
                .font(AtlasFont.mono(10))
                // Soft gold-quiet council provider meta.
                .foregroundStyle(AtlasTheme.accent.opacity(0.62))
                .accessibilityHidden(true)
            providerModelLabel
            Spacer()
            providerStatus
        }
    }
}

extension ChangeReviewCouncilMemberRow {
    @ViewBuilder
    var providerModelLabel: some View {
        if let model = member.model {
            Text(model)
                .font(AtlasFont.mono(9))
                // Soft gold-quiet council model meta.
                .foregroundStyle(AtlasTheme.accent.opacity(0.55))
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

extension ChangeReviewCouncilMemberRow {
    var providerStatus: some View {
        Text(member.status)
            .font(AtlasFont.mono(9))
            .foregroundStyle(member.succeeded ? AtlasCodePalette.healed : AtlasTheme.alert)
            .accessibilityHidden(true)
    }
}

extension ChangeReviewCouncilMemberRow {
    @ViewBuilder
    var metaRow: some View {
        HStack(spacing: 8) {
            metaHashCode
            metaLatency
        }
    }
}

extension ChangeReviewCouncilMemberRow {
    @ViewBuilder
    var metaHashCode: some View {
        if let hash = member.responseHash {
            Text("Hash \(String(hash.prefix(12)))")
                .font(AtlasFont.mono(9))
                // Soft gold-quiet hash meta.
                .foregroundStyle(AtlasTheme.accent.opacity(0.55))
                .accessibilityHidden(true)
        }
        if let code = member.errorCode {
            Text(code)
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.alert)
                .accessibilityHidden(true)
        }
    }
}

extension ChangeReviewCouncilMemberRow {
    @ViewBuilder
    var metaLatency: some View {
        if let latency = member.latencyMs {
            Text("\(latency)ms")
                .font(AtlasFont.mono(9))
                // Soft gold-quiet latency meta.
                .foregroundStyle(AtlasTheme.accent.opacity(0.55))
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }
}


// Cycle 044 fuse → ChangeReviewDiffSection.swift

// MARK: - Patch / Diff (C15 · C16)

struct ChangeReviewPatchCard: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let patch: AtlasTraceChangeReview.Patch
    @Binding var expandedDiffPatch: String?
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        patchCardShell
    }
}

/// Só contagens e flags publicadas pelo servidor; diff expandido é estado local honesto.

enum ChangeReviewPatchA11y {
    static func spokenCard(patch: AtlasTraceChangeReview.Patch, diffExpanded: Bool) -> String {
        ChangeReviewPatchA11yCard.spokenCard(patch: patch, diffExpanded: diffExpanded)
    }

    static func spokenDiffToggle(expanded: Bool) -> String {
        ChangeReviewPatchA11yToggle.spokenDiffToggle(expanded: expanded)
    }

    static func spokenRiskFlags(_ flags: [String]) -> String {
        ChangeReviewPatchA11yToggle.spokenRiskFlags(flags)
    }
}

enum ChangeReviewPatchA11yCard {
    static func spokenDiffState(expanded: Bool) -> String {
        expanded ? "Diff expandido" : "Diff recolhido"
    }

    static func spokenFileCounts(changed: Int, created: Int, deleted: Int) -> String? {
        let total = changed + created + deleted
        guard total > 0 else { return nil }
        var fileParts: [String] = []
        if changed > 0 { fileParts.append("\(changed) alterado\(changed == 1 ? "" : "s")") }
        if created > 0 { fileParts.append("\(created) novo\(created == 1 ? "" : "s")") }
        if deleted > 0 { fileParts.append("\(deleted) removido\(deleted == 1 ? "" : "s")") }
        return fileParts.joined(separator: ", ")
    }

    static func spokenRiskFlags(_ flags: [String]) -> String? {
        guard !flags.isEmpty else { return nil }
        return "Alertas \(flags.joined(separator: ", "))"
    }

    static func spokenCard(patch: AtlasTraceChangeReview.Patch, diffExpanded: Bool) -> String {
        var parts = ["Patch \(String(patch.id.prefix(8)))"]
        if let files = spokenFileCounts(
            changed: patch.changedFiles.count,
            created: patch.createdFiles.count,
            deleted: patch.deletedFiles.count
        ) {
            parts.append(files)
        }
        if let risk = spokenRiskFlags(patch.riskFlags) {
            parts.append(risk)
        }
        parts.append(spokenDiffState(expanded: diffExpanded))
        return parts.joined(separator: ", ")
    }
}

enum ChangeReviewPatchA11yToggle {
    static func spokenDiffToggle(expanded: Bool) -> String {
        expanded ? "Fechar diff do patch" : "Ver diff do patch"
    }

    static func spokenRiskFlags(_ flags: [String]) -> String {
        "Alertas de risco, \(flags.joined(separator: ", "))"
    }
}

extension ChangeReviewPatchCard {
    @ViewBuilder
    var patchCardBody: some View {
        VStack(alignment: .leading, spacing: 10) {
            patchHeader
            ForEach(patch.changedFiles + patch.createdFiles + patch.deletedFiles, id: \.self) { file in
                ChangeReviewFileRow(reviews: reviews, traceId: traceId, patch: patch, file: file)
            }
            patchRiskFlags
            if diffExpanded {
                ChangeReviewDiffView(reviews: reviews, traceId: traceId, patch: patch)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

extension ChangeReviewPatchCard {
    func patchCardChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .atlasCard()
            .atlasElevation(radius: 8, y: 2, opacity: 0.12)
            // Contain without fused label: Ver/Fechar diff stays a button.
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.reviewPatchCard(patch.id))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: diffExpanded)
    }
}

extension ChangeReviewPatchCard {
    var diffExpanded: Bool { expandedDiffPatch == patch.id }
}

extension ChangeReviewPatchCard {
    var patchCardShell: some View {
        patchCardChrome { patchCardBody }
    }
}

extension ChangeReviewPatchCard {
    func toggleDiff() {
        if diffExpanded {
            expandedDiffPatch = nil
        } else {
            expandedDiffPatch = patch.id
            Task { await reviews.refreshChangeReviewDiff(traceId: traceId, patchId: patch.patchID) }
        }
    }
}

extension ChangeReviewPatchCard {
    var patchHeader: some View {
        HStack {
            Text("Patch \(String(patch.id.prefix(8)))")
                // Soft gold-quiet patch hash kicker.
                .font(AtlasFont.mono(10)).tracking(0.3).foregroundStyle(AtlasTheme.accent.opacity(0.62))
                .accessibilityHidden(true)
            Spacer()
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                toggleDiff()
            } label: {
                Text(diffExpanded ? "Fechar diff" : "Ver diff")
                    .font(AtlasFont.serif(13, .medium))
                    .foregroundStyle(AtlasTheme.accent)
                    .padding(.horizontal, 12)
                    .frame(minHeight: 48)
                    .background(Capsule().fill(AtlasTheme.goldVeil.opacity(diffExpanded ? 0.55 : 0.35)))
                    .overlay(Capsule().stroke(AtlasTheme.goldBorder.opacity(diffExpanded ? 1 : 0.7), lineWidth: 1))
                    .atlasElevation(radius: 5, y: 1, opacity: diffExpanded ? 0.12 : 0.08)
                    .contentShape(Capsule())
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel(ChangeReviewPatchA11y.spokenDiffToggle(expanded: diffExpanded))
            .accessibilityHint("Mostra ou oculta o conteúdo do diff para este patch")
            .accessibilityIdentifier(A11yID.reviewPatchDiff(patch.id))
            .accessibilityAddTraits(diffExpanded ? [.isButton, .isSelected] : .isButton)
        }
    }
}

extension ChangeReviewPatchCard {
    var patchRiskFlags: some View {
        Group {
            if !patch.riskFlags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(patch.riskFlags, id: \.self) { flag in
                        Text(flag).font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.domOperacional)
                            .padding(.horizontal, 7).padding(.vertical, 3)
                            .background(Capsule().fill(AtlasTheme.domOperacional.opacity(0.08)))
                            .overlay(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.4), lineWidth: 1))
                            .atlasElevation(radius: 3, y: 1, opacity: 0.1)
                            .accessibilityHidden(true)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(ChangeReviewPatchA11y.spokenRiskFlags(patch.riskFlags))
            }
        }
    }
}


// Cycle 043 fuse → ChangeReviewFileRow.swift

/// Ações: +Actions · a11y: +A11y · Trailing: +Trailing · Meta: +Meta.
struct ChangeReviewFileRow: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let patch: AtlasTraceChangeReview.Patch
    let file: String
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        fileLeading
            .padding(.vertical, 3)
            .modifier(ChangeReviewFileRowA11y(
                decidedLabel: decided.map {
                    ChangeReviewFileRowA11y.spoken(displayName: displayName, kind: fileKindCaption, review: $0)
                },
                identifier: A11yID.reviewFileRow(patchId: patch.id, filePath: file)
            ))
    }
}

extension ChangeReviewFileRow {
    var acceptButton: some View {
        Button {
            // Medium: per-file accept is a governed review commit.
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            Task {
                await reviews.applyChangeReviewFile(
                    traceId: traceId, patchId: patch.patchID,
                    filePath: file, action: .accept
                )
            }
        } label: {
            Text("Aceitar")
                .font(AtlasFont.mono(10, .medium))
                .foregroundStyle(AtlasTheme.accent)
                .padding(.horizontal, 12)
                .frame(minHeight: 48)
                .background(Capsule().fill(AtlasTheme.goldVeil))
                .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1))
                .atlasElevation(radius: 6, y: 2, opacity: 0.12)
                .contentShape(Capsule())
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("Aceitar \(displayName)")
        .accessibilityHint("Registra aceite deste arquivo no patch")
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(8)
        .accessibilityIdentifier(A11yID.reviewFileAccept(patchId: patch.id, filePath: file))
    }
}

extension ChangeReviewFileRow {
    var rejectButton: some View {
        Button {
            // Medium: per-file reject is a governed review commit.
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            Task {
                await reviews.applyChangeReviewFile(
                    traceId: traceId, patchId: patch.patchID,
                    filePath: file, action: .reject
                )
            }
        } label: {
            Text("Rejeitar")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.domOperacional)
                .padding(.horizontal, 12)
                .frame(minHeight: 48)
                .background(Capsule().fill(AtlasTheme.domOperacional.opacity(0.08)))
                .overlay(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.35), lineWidth: 1))
                .atlasElevation(radius: 6, y: 2, opacity: 0.1)
                .contentShape(Capsule())
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("Rejeitar \(displayName)")
        .accessibilityHint("Registra rejeição deste arquivo no patch")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(A11yID.reviewFileReject(patchId: patch.id, filePath: file))
    }
}

/// Pending = contain (botões focáveis); decided = ignore + rótulo composto.
struct ChangeReviewFileRowA11y: ViewModifier {
    let decidedLabel: String?
    let identifier: String

    func body(content: Content) -> some View {
        if let decidedLabel {
            content
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(decidedLabel)
                .accessibilityIdentifier(identifier)
        } else {
            content
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier(identifier)
        }
    }
}

extension ChangeReviewFileRowA11y {
    static func spoken(
        displayName: String,
        kind: String?,
        review: AtlasTraceChangeReview.FileReview
    ) -> String {
        var parts = [displayName]
        if let kind { parts.append("arquivo \(kind)") }
        parts.append(review.action == .accept ? "aceito" : "rejeitado")
        return parts.joined(separator: ", ")
    }
}

extension ChangeReviewFileRow {
    var decided: AtlasTraceChangeReview.FileReview? {
        patch.fileReviews.first { $0.filePath == file }
    }

    var displayName: String { (file as NSString).lastPathComponent }

    var fileKindCaption: String? {
        if patch.createdFiles.contains(file) { return "novo" }
        if patch.deletedFiles.contains(file) { return "removido" }
        return nil
    }
}

extension ChangeReviewFileRow {
    var fileLeading: some View {
        fileLeadingRow
    }
}

extension ChangeReviewFileRow {
    var fileLeadingRow: some View {
        HStack(spacing: 8) {
            Text(displayName)
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                .accessibilityHidden(true)
            if let kind = fileKindCaption {
                Text(kind).font(AtlasFont.mono(9))
                    .foregroundStyle(kind == "novo" ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
                    .accessibilityHidden(true)
            }
            Spacer()
            fileTrailing
        }
    }
}

extension ChangeReviewFileRow {
    @ViewBuilder
    var fileTrailing: some View {
        if let decided {
            Text(decided.action == .accept ? "aceito" : "rejeitado")
                .font(AtlasFont.mono(10))
                .foregroundStyle(decided.action == .accept ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
                .accessibilityHidden(true)
        } else {
            acceptButton
            rejectButton
        }
    }
}


// Cycle 044 fuse → ChangeReviewDiffView.swift

struct ChangeReviewDiffView: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let patch: AtlasTraceChangeReview.Patch
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var loadSettled = false

    var body: some View {
        Group {
            diffBody(response: reviews.changeReviewDiff(traceId: traceId, patchId: patch.patchID))
        }
        .task(id: patch.id) {
            await diffLoadTask()
        }
    }
}

extension ChangeReviewDiffView {
    @ViewBuilder
    var diffBodyLoading: some View {
        TraceEvidenceLoading(text: "carregando diff…", reduceMotion: reduceMotion)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
    }
}

extension ChangeReviewDiffView {
    @ViewBuilder
    var diffBodyUnavailable: some View {
        Text("Diff indisponível para este patch")
            .font(AtlasFont.serifItalic(13))
            // Soft gold-quiet unavailable honesty.
            .foregroundStyle(AtlasTheme.accent.opacity(0.62))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .accessibilityLabel("Diff indisponível para este patch")
            .accessibilityIdentifier(A11yID.reviewDiffUnavailable)
    }
}

extension ChangeReviewDiffView {
    @ViewBuilder
    func diffBody(response: AtlasTraceChangeReviewDiffResponse?) -> some View {
        if let response {
            loadedDiff(response)
        } else if !loadSettled {
            diffBodyLoading
        } else {
            diffBodyUnavailable
        }
    }
}

extension ChangeReviewDiffView {
    @ViewBuilder
    func loadedDiffScroll(_ response: AtlasTraceChangeReviewDiffResponse) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(response.diff.content)
                .font(AtlasFont.mono(10))
                // Soft gold-quiet mono diff content — brand warmth, still readable.
                .foregroundStyle(AtlasTheme.accent.opacity(0.72))
                .textSelection(.enabled)
                .padding(10)
        }
        .frame(maxHeight: 320)
        .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.bgRecessed))
        // Diff pane floats slightly above the review surface.
        .atlasElevation(radius: 6, y: 2, opacity: 0.1)
    }
}

extension ChangeReviewDiffView {
    @ViewBuilder
    func loadedDiff(_ response: AtlasTraceChangeReviewDiffResponse) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            loadedDiffScroll(response)
            loadedDiffWarnings(response)
        }
        .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
    }
}

extension ChangeReviewDiffView {
    func diffLoadTask() async {
        loadSettled = false
        if reviews.changeReviewDiff(traceId: traceId, patchId: patch.patchID) == nil {
            await reviews.refreshChangeReviewDiff(traceId: traceId, patchId: patch.patchID)
        }
        loadSettled = true
    }
}

extension ChangeReviewDiffView {
    @ViewBuilder
    func loadedDiffWarnings(_ response: AtlasTraceChangeReviewDiffResponse) -> some View {
        if response.diff.truncated {
            Text("Diff truncado — \(response.diff.returnedBytes) de \(response.diff.sizeBytes) bytes")
                // Soft gold-quiet truncation honesty.
                .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.accent.opacity(0.62))
        }
        if response.patch.hashMatches == false {
            hashMismatchWarning
        }
    }

    var hashMismatchWarning: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .atlasSans(11, .semibold)
                .foregroundStyle(AtlasTheme.domOperacional)
                .accessibilityHidden(true)
            Text("Atenção: o hash do diff não confere com o artefato registrado")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.domOperacional)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Atenção: o hash do diff não confere com o artefato registrado")
        .accessibilityIdentifier(A11yID.reviewHashWarning)
    }
}


// Cycle 044 fuse → ChangeReviewSections.swift

// MARK: - Seções remanescentes da ChangeReviewSheet (C15 · C16)

struct ChangeReviewRunHeader: View {
    let run: AtlasTraceChangeReview.Run

    var body: some View {
        runHeaderChrome {
            runHeaderFields
        }
    }
}

/// Só campos publicados pelo servidor; score/decisão verbatim; toast = texto real.

enum ChangeReviewSectionsA11y {
    static func spokenControl(_ control: AtlasTraceChangeReview.Control) -> String {
        "\(control.slug), status \(control.status), \(control.signalSummary)"
    }
}

extension ChangeReviewSectionsA11y {
    static func spokenTest(_ test: AtlasTraceChangeReview.TestRun) -> String {
        "\(test.command ?? "teste"), status \(test.status)"
    }
}

extension ChangeReviewSectionsA11y {
    static func spokenDecidedAction(_ action: AtlasTraceChangeReview.OperatorAction) -> String {
        var parts = [action.action == .accept ? "aceito" : "rejeitado"]
        if let at = action.actedAt?.nonEmpty { parts.append(at) }
        return parts.joined(separator: ", ")
    }
}

extension ChangeReviewSectionsA11y {
    static func spokenRunHeader(run: AtlasTraceChangeReview.Run) -> String {
        var parts = [run.decision ?? run.status ?? "revisão"]
        if let finished = run.finishedAt?.nonEmpty { parts.append("concluída \(finished)") }
        if let score = run.score { parts.append("pontuação \(score)") }
        return parts.joined(separator: ", ")
    }
}

extension ChangeReviewSectionsA11y {
    static func spokenToast(_ text: String) -> String {
        "Aviso, \(text)"
    }
}

struct ChangeReviewControlsSection: View {
    let controls: [AtlasTraceChangeReview.Control]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("Controles · \(controls.count)")
            ForEach(controls) { c in
                controlRow(c)
            }
        }
        // Contain without fused label: caption header + control rows stay focusable.
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.reviewControlsSection)
    }
}

struct ChangeReviewCaption: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        // Soft gold-quiet section caption — same family as home/radar kickers.
        Text(text).font(AtlasFont.mono(10)).tracking(0.4).foregroundStyle(AtlasTheme.accent.opacity(0.72))
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(text)
    }
}

struct ChangeReviewDecidedSection: View {
    let actions: [AtlasTraceChangeReview.OperatorAction]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("Decisões registradas")
            ForEach(actions) { a in
                decidedActionRow(a)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.reviewDecidedSection)
    }
}

extension ChangeReviewDecidedSection {
    func decidedActionRow(_ a: AtlasTraceChangeReview.OperatorAction) -> some View {
        HStack(spacing: 8) {
            Text(a.action == .accept ? "aceito" : "rejeitado")
                .font(AtlasFont.mono(10))
                .foregroundStyle(a.action == .accept ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
            if let at = a.actedAt {
                // Soft gold-quiet decided timestamp.
                Text(at).font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.accent.opacity(0.55))
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(ChangeReviewSectionsA11y.spokenDecidedAction(a))
    }
}

extension ChangeReviewRunHeader {
    func runHeaderChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).fill(AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).stroke(AtlasTheme.goldBorder, lineWidth: 1))
            // Gold-bordered masthead shares card elevation with accept CTAs.
            .atlasElevation(radius: 10, y: 3, opacity: 0.14)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(ChangeReviewSectionsA11y.spokenRunHeader(run: run))
            .accessibilityIdentifier(A11yID.reviewRunHeader)
    }
}

extension ChangeReviewTestsSection {
    func testRow(_ t: AtlasTraceChangeReview.TestRun) -> some View {
        HStack(spacing: 8) {
            Text(t.command ?? "teste").font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                .accessibilityHidden(true)
            Spacer()
            Text(t.status).font(AtlasFont.mono(10))
                .foregroundStyle(t.status == "passed" ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ChangeReviewSectionsA11y.spokenTest(t))
    }
}

struct ChangeReviewTestsSection: View {
    let tests: [AtlasTraceChangeReview.TestRun]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("Testes · \(tests.count)")
            ForEach(tests) { t in
                testRow(t)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.reviewTestsSection)
    }
}

struct ChangeReviewToast: View {
    let reviews: ChangeReviewModel
    var reduceMotion: Bool = false

    var body: some View {
        if let t = reviews.toast {
            toastCapsule(t)
                .accessibilityLabel(ChangeReviewSectionsA11y.spokenToast(t))
                .accessibilityAddTraits(.updatesFrequently)
                .accessibilitySortPriority(12) // transient status over review chrome
                .accessibilityIdentifier(A11yID.reviewToast)
                .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                .task { await dismissToastAfterDelay() }
        }
    }
}

extension ChangeReviewToast {
    func toastCapsule(_ text: String) -> some View {
        Text(text)
            .font(AtlasFont.serifItalic(14)).foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 16).padding(.vertical, 9)
            .frame(minHeight: 48)
            .background(Capsule().fill(AtlasTheme.surfaceHi).overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
            .atlasElevation(radius: 10, y: 3, opacity: 0.2)
            .padding(.top, 8)
    }

    func dismissToastAfterDelay() async {
        try? await Task.sleep(nanoseconds: 1_400_000_000)
        if reduceMotion { reviews.toast = nil }
        else { withAnimation(AtlasMotion.editorial) { reviews.toast = nil } }
    }
}

extension ChangeReviewControlsSection {
    func controlRow(_ c: AtlasTraceChangeReview.Control) -> some View {
        HStack(spacing: 8) {
            Text(c.slug).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(c.status).font(AtlasFont.mono(10))
                .foregroundStyle(c.status == "pass" || c.status == "passed" ? AtlasTheme.domAutonomos : AtlasTheme.accent.opacity(0.55))
                .accessibilityHidden(true)
            Spacer()
            // Soft gold-quiet control signal meta.
            Text(c.signalSummary).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.accent.opacity(0.62)).lineLimit(1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ChangeReviewSectionsA11y.spokenControl(c))
    }
}

extension ChangeReviewRunHeader {
    @ViewBuilder
    var runHeaderScore: some View {
        if let score = run.score {
            Text("\(score)").font(AtlasFont.mono(20)).foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
        }
    }
}

extension ChangeReviewRunHeader {
    @ViewBuilder
    var runHeaderTitleStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(run.decision ?? run.status ?? "revisão")
                .font(AtlasFont.serif(20, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            if let finished = run.finishedAt {
                // Soft gold-quiet run finished meta.
                Text(finished).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.accent.opacity(0.62))
                    .accessibilityHidden(true)
            }
        }
    }
}

extension ChangeReviewRunHeader {
    @ViewBuilder
    var runHeaderFields: some View {
        HStack(spacing: 12) {
            runHeaderTitleStack
            Spacer()
            runHeaderScore
        }
    }
}


// Cycle 044 fuse → ChangeReviewFindingsSection.swift

/// Achados agrupados pelo EIXO real que o servidor classificou
/// (`finding.category`) — a leitura por frente do mock, com dado verdadeiro.
/// Sem categoria, o achado cai em "gerais": nada é inventado.
struct ChangeReviewFindingsSection: View {
    let findings: [AtlasTraceChangeReview.Finding]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ChangeReviewCaption("Achados · \(findings.count)")
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel("Achados, \(findings.count) no total")
            ForEach(groups.keys.sorted(), id: \.self) { axis in
                axisGroup(axis: axis, axisFindings: groups[axis] ?? [])
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.reviewFindingsSection)
    }
}

extension ChangeReviewFindingsSection {
    func axisGroup(axis: String, axisFindings: [AtlasTraceChangeReview.Finding]) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            axisHeaderRow(axis: axis, count: axisFindings.count)
            ForEach(axisFindings) { f in
                ChangeReviewFindingRow(finding: f)
            }
        }
    }
}

extension ChangeReviewFindingsSection {
    func axisHeaderLabel(axis: String, count: Int) -> String {
        let name = axis == "GERAIS" ? "gerais" : axis.lowercased()
        let noun = count == 1 ? "achado" : "achados"
        return "Eixo \(name), \(count) \(noun)"
    }
}

extension ChangeReviewFindingsSection {
    var groups: [String: [AtlasTraceChangeReview.Finding]] {
        Dictionary(grouping: findings) { $0.category?.uppercased() ?? "GERAIS" }
    }
}

extension ChangeReviewFindingsSection {
    func axisHeaderRow(axis: String, count: Int) -> some View {
        HStack(spacing: 8) {
            Text(axis.localizedCapitalized).font(AtlasFont.mono(9)).tracking(0.4)
                .foregroundStyle(AtlasTheme.accent)
            // Pure gold-breath — same family as home sectionLabel.
            AtlasGoldBreathHairline()
            Text("\(count)")
                // Soft gold-quiet axis count.
                .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.accent.opacity(0.62))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(axisHeaderLabel(axis: axis, count: count))
        .accessibilityIdentifier(A11yID.reviewFindingAxis(axis))
    }
}


// Cycle 043 fuse → ChangeReviewFindingRow.swift

struct ChangeReviewFindingRow: View {
    let finding: AtlasTraceChangeReview.Finding

    var body: some View {
        findingBody
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(rowAccessibilityLabel)
            .accessibilityIdentifier(A11yID.reviewFindingRow(finding.id))
    }
}

extension ChangeReviewFindingRow {
    var rowAccessibilityLabel: String {
        var parts: [String] = []
        if let severity = finding.severity {
            parts.append("severidade \(Self.severitySpoken(severity))")
        }
        parts.append(finding.title ?? "achado sem título")
        if let path = finding.filePath {
            let line = finding.startLine.map { ", linha \($0)" } ?? ""
            parts.append("\(path)\(line)")
        }
        if let rec = finding.recommendation {
            parts.append("recomendação: \(rec)")
        }
        return parts.joined(separator: ", ")
    }
}

extension ChangeReviewFindingRow {
    @ViewBuilder
    var findingPathAndRecommendation: some View {
        if let path = finding.filePath {
            Text(path + (finding.startLine.map { ":\($0)" } ?? ""))
                // Soft gold-quiet finding path meta.
                .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.accent.opacity(0.55)).lineLimit(1)
                .accessibilityHidden(true)
        }
        if let rec = finding.recommendation {
            // Soft gold-quiet finding recommendation.
            Text(rec).font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.accent.opacity(0.62))
                .lineLimit(3).padding(.top, 1)
                .accessibilityHidden(true)
        }
    }
}

extension ChangeReviewFindingRow {
    static func severityColor(_ s: String) -> Color {
        switch s.lowercased() {
        case "critical", "high": return AtlasTheme.domOperacional
        case "medium": return AtlasTheme.accent
        // Soft gold-quiet low/unknown severity.
        default: return AtlasTheme.accent.opacity(0.55)
        }
    }
}

extension ChangeReviewFindingRow {
    var findingBody: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                if let severity = finding.severity {
                    Text(severity).font(AtlasFont.mono(9))
                        .foregroundStyle(Self.severityColor(severity))
                        .accessibilityHidden(true)
                }
                Text(finding.title ?? "finding").font(AtlasFont.serif(13)).foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(2)
                    .accessibilityHidden(true)
            }
            findingPathAndRecommendation
        }
        .padding(.vertical, 3)
    }
}

extension ChangeReviewFindingRow {
    static func severitySpokenHigh(_ s: String) -> String? {
        switch s.lowercased() {
        case "critical": return "crítica"
        case "high": return "alta"
        default: return nil
        }
    }
}

extension ChangeReviewFindingRow {
    static func severitySpoken(_ s: String) -> String {
        if let high = severitySpokenHigh(s) { return high }
        switch s.lowercased() {
        case "medium": return "média"
        case "low": return "baixa"
        default: return s
        }
    }
}


@MainActor
@Observable
final class ChangeReviewModel {
    /// Revisões carregadas sob demanda e sempre indexadas pelo trace público.
    /// A casca pode mostrar ausência/indisponibilidade, mas não fabricar patch,
    /// resultado de check ou decisão antes desta leitura canônica.
    var changeReviewsByTrace: [TraceID: AtlasTraceChangeReview] = [:]  // set interno: família de peels
    /// Provas de governança do turno (C18 diff_stats · C19 plan_revisions ·
    /// C21 council_review). Vêm do metadata do trace; ausência = nada a dizer.
    var governanceByTrace: [TraceID: AtlasAiTrace] = [:]  // set interno: família de peels
    /// Manifestos de artefatos do turno. `unavailable` pode ser guardado, mas
    /// a casca só renderiza quando o contrato vem `available` com itens reais.
    var artifactsByTrace: [TraceID: AtlasTraceArtifacts] = [:]
    /// Conteúdo de diff só entra aqui depois de o patch ser confirmado na
    /// projeção do mesmo trace; a View nunca faz a requisição por conta própria.
    var changeReviewDiffsByKey: [String: AtlasTraceChangeReviewDiffResponse] = [:]  // set interno: família de peels
    var toast: String?

    @ObservationIgnored var onTraceUpdated: (@MainActor (TraceID, AtlasAiTrace) -> Void)?
    @ObservationIgnored let artifactContentCache = NSCache<NSString, CachedArtifactContent>()
    /// Coalesce: um refresh in-flight por trace (evita 3 GETs × N bolhas no scroll).
    @ObservationIgnored var changeReviewInFlight: Set<TraceID> = []

    let client: AtlasClient

    init(client: AtlasClient) {
        self.client = client
        artifactContentCache.countLimit = 8
    }

    func changeReviewDiff(traceId: TraceID, patchId: PatchID) -> AtlasTraceChangeReviewDiffResponse? {
        changeReviewDiffsByKey[Self.changeReviewDiffKey(traceId: traceId, patchId: patchId)]
    }

    static func changeReviewDiffKey(traceId: TraceID, patchId: PatchID) -> String {
        "\(traceId.rawValue):\(patchId.rawValue)"
    }
}

final class CachedArtifactContent {
    let content: AtlasArtifactContent

    init(_ content: AtlasArtifactContent) {
        self.content = content
    }
}


/// Decisões de revisão (run e arquivo) — fora do shell ChangeReviewModel.
extension ChangeReviewModel {
    /// Aceita ou rejeita o run inteiro através do recibo do servidor. Não há
    /// ação local otimista: a UI só muda depois que a decisão e seu evento no
    /// ledger foram persistidos e devolvidos pela mesma rota trace-scoped.
    func applyChangeReview(
        traceId: TraceID,
        action: AtlasTraceChangeReview.Action,
        note: String? = nil
    ) async {
        do {
            let response = try await client.applyTraceChangeReview(
                traceId: traceId,
                input: .init(action: action, actor: "mobile_operator", note: note)
            )
            guard response.changeReview.traceId == traceId else {
                toast = "A decisão foi recusada porque o recibo não corresponde à execução."
                return
            }
            changeReviewsByTrace[traceId] = response.changeReview
            await notifyTraceUpdated(traceId)
        } catch {
            toast = atlasUserMessage(for: error)
        }
    }

    /// Decide um arquivo somente depois de provar que ele pertence ao patch já
    /// vinculado ao mesmo trace. A resposta também é revalidada antes de tocar
    /// no estado observado pela casca, eliminando aceite cruzado entre runs.
    func applyChangeReviewFile(
        traceId: TraceID,
        patchId: PatchID,
        filePath: String,
        action: AtlasTraceChangeReview.Action,
        note: String? = nil
    ) async {
        if changeReviewsByTrace[traceId] == nil {
            await refreshChangeReview(traceId: traceId)
        }
        guard changeReviewsByTrace[traceId]?.patches.contains(where: { $0.patchID == patchId && $0.contains(filePath) }) == true else {
            toast = "Este arquivo não pertence ao patch desta execução."
            return
        }
        do {
            let response = try await client.applyTraceChangeReviewFile(
                traceId: traceId,
                input: .init(
                    patchId: patchId,
                    filePath: filePath,
                    action: action,
                    actor: "mobile_operator",
                    note: note
                )
            )
            guard response.changeReview.traceId == traceId,
                  response.fileReviewReceipt.patchId == patchId,
                  response.fileReviewReceipt.filePath == filePath,
                  response.fileReviewReceipt.action == action,
                  response.changeReview.patches.contains(where: {
                      $0.patchID == patchId && $0.fileReviews.contains(where: {
                          $0.filePath == filePath && $0.action == action
                      })
                  }) else {
                toast = "A decisão por arquivo não corresponde ao patch revisado."
                return
            }
            changeReviewsByTrace[traceId] = response.changeReview
            await notifyTraceUpdated(traceId)
        } catch {
            toast = atlasUserMessage(for: error)
        }
    }

    func notifyTraceUpdated(_ traceId: TraceID) async {
        if let refreshed = try? await client.getAiInteraction(traceId) {
            onTraceUpdated?(traceId, refreshed.trace)
        }
    }
}


/// Refresh/load da revisão — peel de `ChangeReviewModel.swift`.
extension ChangeReviewModel {
    /// Carrega a superfície de artefatos/revisão do trace. A resposta que não
    /// ecoa o mesmo trace é descartada, pois vinculá-la à bolha errada seria um
    /// vazamento de evidência entre execuções.
    func refreshChangeReview(traceId: TraceID) async {
        // Já temos revisão (ou in-flight): não dispare rede de novo por bolha.
        if changeReviewsByTrace[traceId] != nil { return }
        guard !changeReviewInFlight.contains(traceId) else { return }
        changeReviewInFlight.insert(traceId)
        defer { changeReviewInFlight.remove(traceId) }
        do {
            async let reviewResponse = client.getTraceChangeReview(traceId)
            async let artifactsResponse = client.getTraceArtifacts(traceId: traceId)
            let response = try await reviewResponse
            guard response.changeReview.traceId == traceId else {
                toast = "A revisão recebida não corresponde a esta execução."
                return
            }
            changeReviewsByTrace[traceId] = response.changeReview
            if let artifacts = try? await artifactsResponse {
                artifactsByTrace[traceId] = artifacts
            }
            // O mesmo toque que abre a revisão traz as provas do turno.
            if let trace = try? await client.getAiInteraction(traceId).trace,
               trace.id == traceId.rawValue || trace.traceKey == traceId.rawValue {
                governanceByTrace[traceId] = trace
            }
        } catch {
            toast = atlasUserMessage(for: error)
        }
    }

    func loadArtifactContent(traceId: TraceID, item: AtlasTraceArtifacts.Item) async throws -> AtlasArtifactContent {
        guard artifactsByTrace[traceId]?.state == .available,
              artifactsByTrace[traceId]?.items.contains(where: { $0.id == item.id && $0.sha256 == item.sha256 }) == true else {
            let error = AtlasApiError(status: 0, path: "trace-artifacts", message: "Este artefato não pertence ao manifesto desta execução.")
            toast = error.message
            throw error
        }

        let key = NSString(string: item.sha256)
        if let cached = artifactContentCache.object(forKey: key) {
            return cached.content
        }

        do {
            let content = try await client.getTraceArtifactContent(traceId: traceId, item: item)
            artifactContentCache.setObject(CachedArtifactContent(content), forKey: key)
            return content
        } catch {
            toast = atlasUserMessage(for: error)
            throw error
        }
    }

    /// Busca o diff somente se o patch já pertence à revisão canônica do trace.
    /// Isso evita tanto rede na casca quanto a mistura de artefatos entre traces.
    func refreshChangeReviewDiff(traceId: TraceID, patchId: PatchID) async {
        if changeReviewsByTrace[traceId] == nil {
            await refreshChangeReview(traceId: traceId)
        }
        guard changeReviewsByTrace[traceId]?.patches.contains(where: { $0.patchID == patchId }) == true else {
            toast = "Este diff não pertence à revisão desta execução."
            return
        }
        do {
            let response = try await client.getTraceChangeReviewDiff(traceId: traceId, patchId: patchId)
            guard response.patch.patchID == patchId else {
                toast = "O diff recebido não corresponde ao artefato solicitado."
                return
            }
            changeReviewDiffsByKey[Self.changeReviewDiffKey(traceId: traceId, patchId: patchId)] = response
        } catch {
            toast = atlasUserMessage(for: error)
        }
    }
}
