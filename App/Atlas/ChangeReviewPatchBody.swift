import AtlasCore
import SwiftUI

// IDLE-COMPRESS peel from ChangeReviewSections (canon §7.2 · same domain)

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
    static func spokenCard(patch: AtlasTraceChangeReview.Patch, diffExpanded: Bool) -> String {
        var parts = ["patch \(String(patch.id.prefix(8)))"]
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
        expanded ? "fechar diff do patch" : "ver diff do patch"
    }

    static func spokenRiskFlags(_ flags: [String]) -> String {
        "alertas de risco, \(flags.joined(separator: ", "))"
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
    var diffExpanded: Bool { expandedDiffPatch == patch.id }
}

extension ChangeReviewPatchCard {
    var patchHeader: some View {
        HStack {
            Text("PATCH \(String(patch.id.prefix(8)))")
                .font(AtlasFont.mono(10)).tracking(0.8).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer()
            Button(diffExpanded ? "Fechar diff" : "Ver diff") { toggleDiff() }
                .font(AtlasFont.mono(11, .medium)).foregroundStyle(AtlasTheme.accent)
                .accessibilityLabel(ChangeReviewPatchA11y.spokenDiffToggle(expanded: diffExpanded))
                .accessibilityHint("mostra ou oculta o conteúdo do diff para este patch")
                .accessibilityIdentifier(A11yID.reviewPatchDiff(patch.id))
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
                            .background(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.4), lineWidth: 1))
                            .accessibilityHidden(true)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(ChangeReviewPatchA11y.spokenRiskFlags(patch.riskFlags))
            }
        }
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

// MARK: - Patch / Diff (C15 · C16)
// DiffView → ChangeReviewDiffView.swift · Toggle → +Toggle · Header → +Header
// Chrome → ChangeReviewDiffSection+Chrome.swift
// Body → ChangeReviewDiffSection+Body.swift
// Expanded → ChangeReviewDiffSection+Expanded.swift
// Shell → ChangeReviewDiffSection+Shell.swift

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
        Text("diff indisponível para este patch")
            .font(AtlasFont.serifItalic(13))
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .accessibilityLabel("diff indisponível para este patch")
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
    func loadedDiffScroll(_ response: AtlasTraceChangeReviewDiffResponse) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(response.diff.content)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
                .textSelection(.enabled)
                .padding(10)
        }
        .frame(maxHeight: 320)
        .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.bgRecessed))
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
    @ViewBuilder
    func loadedDiffWarnings(_ response: AtlasTraceChangeReviewDiffResponse) -> some View {
        if response.diff.truncated {
            Text("diff truncado — \(response.diff.returnedBytes) de \(response.diff.sizeBytes) bytes")
                .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
        }
        if response.patch.hashMatches == false {
            ChangeReviewHashWarning()
        }
    }
}

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
    var acceptButton: some View {
        Button("aceitar") {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            Task {
                await reviews.applyChangeReviewFile(
                    traceId: traceId, patchId: patch.patchID,
                    filePath: file, action: .accept
                )
            }
        }
        .buttonStyle(PressableScale())
        .font(AtlasFont.mono(10, .medium)).foregroundStyle(AtlasTheme.accent)
        .accessibilityLabel("aceitar \(displayName)")
        .accessibilityHint("registra aceite deste arquivo no patch")
        .accessibilityIdentifier(A11yID.reviewFileAccept(patchId: patch.id, filePath: file))
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
    var rejectButton: some View {
        Button("rejeitar") {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            Task {
                await reviews.applyChangeReviewFile(
                    traceId: traceId, patchId: patch.patchID,
                    filePath: file, action: .reject
                )
            }
        }
        .buttonStyle(PressableScale())
        .font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
        .accessibilityLabel("rejeitar \(displayName)")
        .accessibilityHint("registra rejeição deste arquivo no patch")
        .accessibilityIdentifier(A11yID.reviewFileReject(patchId: patch.id, filePath: file))
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

