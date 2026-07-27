import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: density split — governance

// MARK: - ChangeReviewGovernance

// MARK: - Body

// WAVE-013 fused ChangeReviewView+Sections.swift

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
            .atlasSans(10, .semibold)
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
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
            providerModelLabel
            Spacer()
            providerStatus
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
            Text(ChangeReviewJudgment.productHashPrefix(hash))
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
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
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }
}

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

// MARK: - Chrome

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
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ChangeReviewJudgment.spokenCouncilSection(memberCount: council.count, diverged: diverged))
        .accessibilityIdentifier(A11yID.reviewCouncil)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: council.map(\.id))
    }
}

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func councilBlockHeader(diverged: Bool) -> some View {
        HStack(spacing: 8) {
            Text(ChangeReviewJudgment.productCouncil)
                .atlasSans(12, .semibold)
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityAddTraits(.isHeader)
            if diverged {
                Text(ChangeReviewJudgment.productDivergence)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityLabel(ChangeReviewJudgment.spokenCouncilDivergence)
            }
        }
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
            let pack = ChangeReviewJudgment.packGovernanceFacts(
                stats: stats,
                revisionCount: revisions.count,
                councilCount: council.count,
                diverged: AtlasTraceGovernance.councilDiverged(council)
            )
            governanceChrome {
                governanceContentStack(
                    stats: stats,
                    revisions: revisions,
                    council: council
                )
            }
            .accessibilityValue(
                (pack.facts + pack.absences.map { "ausência: \($0)" })
                    .joined(separator: "; ")
            )
        }
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
                    .atlasSans(12)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                Text(revisions.count == 1
                     ? "plano v1 arquivado — \(last.humanReason)"
                     : "\(revisions.count) versões de plano arquivadas — \(last.humanReason)")
                    .atlasSans(12)
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        }
    }
}

extension ChangeReviewGovernanceSection {
    @ViewBuilder
    func governanceStatsLine(_ stats: AtlasTraceGovernance.DiffStats) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "plusminus")
                .atlasSans(12)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(stats.headline)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityLabel(ChangeReviewJudgment.spokenDiffStats(stats))
        }
    }
}

// MARK: - Governance / Conselho (C18 · C19 · C21)
// Stats/Revisions → +StatsLine/+RevisionsLine · Council block → +Block.swift
// Chrome → ChangeReviewCouncilSection+Chrome.swift
// Content → ChangeReviewCouncilSection+Content.swift

/// C18 · C19 · C21 — as provas que o servidor emite. Cada bloco só existe
/// se a fonte existir: sem diff medido, sem replanejamento e sem conselho,
/// esta seção inteira desaparece (estado por exceção).
struct ChangeReviewGovernanceSection: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        governanceTraceGate
    }
}


extension ChangeReviewGovernanceSection {
    @ViewBuilder
    var governanceTraceGate: some View {
        if let trace = reviews.governanceByTrace[traceId] {
            let stats = AtlasTraceGovernance.diffStats(from: trace.metadata)
            let revisions = AtlasTraceGovernance.planRevisions(from: trace.metadata)
            let council = AtlasTraceGovernance.councilReview(from: trace.metadata)
            governanceContent(stats: stats, revisions: revisions, council: council)
        }
    }
}

struct ChangeReviewHashWarning: View {
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .atlasSans(12, .semibold)
                .foregroundStyle(AtlasTheme.domOperacional)
                .accessibilityHidden(true)
            Text(ChangeReviewJudgment.spokenHashWarning)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.domOperacional)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(ChangeReviewJudgment.spokenHashWarning)
        .accessibilityIdentifier(A11yID.reviewHashWarning)
    }
}

// Provider model label — peel de ChangeReviewCouncilRow+Header.

extension ChangeReviewCouncilMemberRow {
    @ViewBuilder
    var providerModelLabel: some View {
        if let model = member.model {
            Text(model)
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}
