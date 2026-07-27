import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: density split — body chrome

// MARK: - Controls

struct ChangeReviewControlsSection: View {
    let controls: [AtlasTraceChangeReview.Control]

    private var ranked: [AtlasTraceChangeReview.Control] {
        ChangeReviewJudgment.rankControls(controls)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("CONTROLES · \(controls.count)")
            ForEach(ranked) { c in
                controlRow(c)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ChangeReviewJudgment.spokenControlsSection(ranked))
        .accessibilityIdentifier(A11yID.reviewControlsSection)
    }

    func controlRow(_ c: AtlasTraceChangeReview.Control) -> some View {
        HStack(spacing: 8) {
            Text(c.slug).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(c.status).font(AtlasFont.mono(10))
                .foregroundStyle(c.status == "pass" || c.status == "passed" ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer()
            Text(c.signalSummary).font(.caption2).foregroundStyle(AtlasTheme.textTertiary).lineLimit(1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ChangeReviewJudgment.spokenControl(c))
    }
}

// MARK: - Decided actions

struct ChangeReviewDecidedSection: View {
    let actions: [AtlasTraceChangeReview.OperatorAction]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("DECISÕES REGISTRADAS")
            ForEach(actions) { a in
                decidedActionRow(a)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ChangeReviewJudgment.spokenDecidedSection(actions))
        .accessibilityIdentifier(A11yID.reviewDecidedSection)
    }

    func decidedActionRow(_ a: AtlasTraceChangeReview.OperatorAction) -> some View {
        HStack(spacing: 8) {
            Text(a.action == .accept ? "aceito" : "rejeitado")
                .font(AtlasFont.mono(10))
                .foregroundStyle(a.action == .accept ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
            if let at = a.actedAt {
                Text(at).font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(ChangeReviewJudgment.spokenDecidedAction(a))
    }
}

// MARK: - Tests

struct ChangeReviewTestsSection: View {
    let tests: [AtlasTraceChangeReview.TestRun]

    private var ranked: [AtlasTraceChangeReview.TestRun] {
        ChangeReviewJudgment.rankTests(tests)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("TESTES · \(tests.count)")
            ForEach(ranked) { t in
                testRow(t)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ChangeReviewJudgment.spokenTestsSection(ranked))
        .accessibilityIdentifier(A11yID.reviewTestsSection)
    }

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
        .accessibilityLabel(ChangeReviewJudgment.spokenTest(t))
    }
}

// MARK: - Run header

struct ChangeReviewRunHeader: View {
    let run: AtlasTraceChangeReview.Run

    var body: some View {
        runHeaderChrome {
            runHeaderFields
        }
    }

    @ViewBuilder
    var runHeaderFields: some View {
        HStack(spacing: 12) {
            runHeaderTitleStack
            Spacer()
            runHeaderScore
        }
    }

    @ViewBuilder
    var runHeaderTitleStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(run.decision ?? run.status ?? "revisão")
                .font(AtlasFont.serif(20, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            if let finished = run.finishedAt {
                Text(finished).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
    }

    @ViewBuilder
    var runHeaderScore: some View {
        if let score = run.score {
            Text("\(score)").font(AtlasFont.mono(20)).foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Risk face strip (WAVE-039)

/// Thin chrome: exclusive risk face for Revisar mudanças.
struct ChangeReviewRiskStrip: View {
    let review: AtlasTraceChangeReview
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var face: ChangeReviewRiskFace {
        ChangeReviewJudgment.face(from: review)
    }

    var body: some View {
        switch face {
        case .empty:
            EmptyView()
        case .quiet, .elevated, .critical:
            stripChrome
        }
    }

    private var stripChrome: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Circle()
                .fill(dotColor)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(face.kicker)
                    .font(AtlasFont.mono(10))
                    .tracking(0.8)
                    .foregroundStyle(titleColor)
                Text(ChangeReviewJudgment.productSummaryLine(from: review))
                    .font(AtlasFont.serif(14))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AtlasTheme.Radius.control)
                .fill(AtlasTheme.surface.opacity(0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AtlasTheme.Radius.control)
                .stroke(borderColor, lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(face.spokenFace + ", " + ChangeReviewJudgment.productSummaryLine(from: review))
        .accessibilityIdentifier(A11yID.reviewRiskFace)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: face.productWord)
    }

    private var dotColor: Color {
        switch face {
        case .critical: return AtlasTheme.domOperacional
        case .elevated: return AtlasTheme.accent
        case .quiet: return AtlasTheme.textTertiary
        case .empty: return AtlasTheme.textTertiary
        }
    }

    private var titleColor: Color {
        switch face {
        case .critical: return AtlasTheme.domOperacional
        case .elevated: return AtlasTheme.accent
        case .quiet, .empty: return AtlasTheme.textTertiary
        }
    }

    private var borderColor: Color {
        switch face {
        case .critical: return AtlasTheme.domOperacional.opacity(0.35)
        case .elevated: return AtlasTheme.accent.opacity(0.28)
        case .quiet, .empty: return AtlasTheme.separatorSoft
        }
    }
}

// MARK: - ChangeReviewFindings

extension ChangeReviewFindingRow {
    var rowAccessibilityLabel: String {
        var parts: [String] = []
        if finding.severity != nil {
            parts.append("severidade \(ChangeReviewJudgment.severitySpoken(finding.severity))")
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
    var findingBody: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                if let severity = finding.severity {
                    Text(severity).font(AtlasFont.mono(9))
                        .foregroundStyle(ChangeReviewJudgment.severityColor(severity))
                        .accessibilityHidden(true)
                }
                Text(finding.title ?? "finding").font(AtlasFont.serif(14)).foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(2)
                    .accessibilityHidden(true)
            }
            findingPathAndRecommendation
        }
        .padding(.vertical, 4)
    }
}

extension ChangeReviewFindingRow {
    @ViewBuilder
    var findingPathAndRecommendation: some View {
        if let path = finding.filePath {
            Text(path + (finding.startLine.map { ":\($0)" } ?? ""))
                .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary).lineLimit(1)
                .accessibilityHidden(true)
        }
        if let rec = finding.recommendation {
            Text(rec).font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(3).padding(.top, 2)
                .accessibilityHidden(true)
        }
    }
}

struct ChangeReviewFindingRow: View {
    let finding: AtlasTraceChangeReview.Finding

    var body: some View {
        findingBody
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(rowAccessibilityLabel)
            .accessibilityIdentifier(A11yID.reviewFindingRow(finding.id))
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
    func axisHeaderRow(axis: String, count: Int) -> some View {
        HStack(spacing: 8) {
            Text(axis).font(AtlasFont.mono(9)).tracking(0.8)
                .foregroundStyle(AtlasTheme.accent)
            Rectangle().fill(AtlasTheme.separatorSoft).frame(height: 1)
            Text("\(count)")
                .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(spokenAxisHeader(axis: axis, count: count))
        .accessibilityIdentifier(A11yID.reviewFindingAxis(axis))
    }
}

extension ChangeReviewFindingsSection {
    func spokenAxisHeader(axis: String, count: Int) -> String {
        let name = axis == "GERAIS" ? "gerais" : axis.lowercased()
        let noun = count == 1 ? "achado" : "achados"
        return "eixo \(name), \(count) \(noun)"
    }
}

extension ChangeReviewFindingsSection {
    /// WAVE-039: axes by worst severity; findings severity-first inside.
    var rankedGroups: [(axis: String, findings: [AtlasTraceChangeReview.Finding])] {
        ChangeReviewJudgment.rankedAxisGroups(findings)
    }
}

struct ChangeReviewFindingsSection: View {
    let findings: [AtlasTraceChangeReview.Finding]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ChangeReviewCaption("ACHADOS · \(findings.count)")
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(ChangeReviewJudgment.spokenFindingsSection(count: findings.count))
            ForEach(rankedGroups, id: \.axis) { group in
                axisGroup(axis: group.axis, axisFindings: group.findings)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.reviewFindingsSection)
    }
}

// MARK: - ChangeReviewPatchCard

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
            Text(ChangeReviewSheetJudgment.productPatchHeader(idPrefix: String(patch.id.prefix(8))))
                .font(AtlasFont.mono(10)).tracking(0.8).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer()
            Button(diffExpanded ? "Fechar diff" : "Ver diff") { toggleDiff() }
                .font(AtlasFont.mono(10, .medium)).foregroundStyle(AtlasTheme.accent)
                .accessibilityLabel(ChangeReviewJudgment.spokenDiffToggle(expanded: diffExpanded))
                .accessibilityHint(ChangeReviewSheetJudgment.spokenDiffToggleHint)
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
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.4), lineWidth: 1))
                            .accessibilityHidden(true)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(ChangeReviewJudgment.spokenRiskFlagsLabel(patch.riskFlags))
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

// MARK: - ChangeReviewRunActions

extension ChangeReviewRunActions {
    var acceptButtonLabel: some View {
        Text(ChangeReviewControlJudgment.productAcceptRun)
            .font(AtlasFont.mono(10, .semibold)).foregroundStyle(AtlasTheme.bg)
            .padding(.horizontal, 18).padding(.vertical, 10)
            .background(Capsule().fill(AtlasTheme.accent))
    }
}

extension ChangeReviewRunActions {
    @ViewBuilder
    var applyingIndicator: some View {
        if reduceMotion {
            applyingStaticLabel
        } else {
            // Mesma razão do loading da Arena: identidade própria na espera.
            BreathingDiamond(size: 9, reduceMotion: reduceMotion)
                .accessibilityLabel(ChangeReviewJudgment.spokenApplying)
        }
    }
}

extension ChangeReviewRunActions {
    var applyingStaticLabel: some View {
        Text(ChangeReviewJudgment.productApplying)
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityLabel(ChangeReviewJudgment.spokenApplying)
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
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
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
            .accessibilityLabel(ChangeReviewJudgment.spokenAccept)
            .accessibilityHint(ChangeReviewJudgment.spokenAcceptHint)
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
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                rejectReviewAction()
            } label: {
                rejectButtonLabel
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel(ChangeReviewJudgment.spokenReject)
            .accessibilityHint(ChangeReviewJudgment.spokenRejectHint)
            .accessibilityIdentifier(A11yID.reviewRunReject)
        }
    }
}

extension ChangeReviewRunActions {
    var rejectButtonLabel: some View {
        Text(ChangeReviewControlJudgment.productRejectRun)
            .font(AtlasFont.mono(10, .semibold)).foregroundStyle(AtlasTheme.domOperacional)
            .padding(.horizontal, 18).padding(.vertical, 10)
            .background(Capsule().fill(AtlasTheme.domOperacional.opacity(0.1)))
            .overlay(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.45), lineWidth: 1))
    }
}

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

// MARK: - File row a11y
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

// MARK: - File row chrome
extension ChangeReviewFileRow {
    var acceptButton: some View {
        Button(ChangeReviewControlJudgment.productAcceptFile) {
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
        .accessibilityLabel(ChangeReviewJudgment.spokenAcceptPatch(displayName))
        .accessibilityHint(ChangeReviewSheetJudgment.spokenAcceptFileHint)
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
                .font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
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
        Button(ChangeReviewControlJudgment.productRejectFile) {
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
        .accessibilityLabel(ChangeReviewJudgment.spokenRejectPatch(displayName))
        .accessibilityHint(ChangeReviewSheetJudgment.spokenRejectFileHint)
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
            .padding(.vertical, 4)
            .modifier(ChangeReviewFileRowA11y(
                decidedLabel: decided.map {
                    ChangeReviewFileRowA11y.spoken(displayName: displayName, kind: fileKindCaption, review: $0)
                },
                identifier: A11yID.reviewFileRow(patchId: patch.id, filePath: file)
            ))
    }
}
