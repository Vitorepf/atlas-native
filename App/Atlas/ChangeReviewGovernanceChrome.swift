import SwiftUI
import AtlasCore

// WAVE-140 governance hash/chrome peel

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
            Text("Conselho")
                .atlasSans(11, .semibold)
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityAddTraits(.isHeader)
            if diverged {
                Text("divergência")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityLabel(ChangeReviewJudgment.councilDivergenceLabel)
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
                    .atlasSans(11)
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
                .atlasSans(11)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(stats.headline)
                .font(AtlasFont.mono(11))
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
                .atlasSans(11, .semibold)
                .foregroundStyle(AtlasTheme.domOperacional)
                .accessibilityHidden(true)
            Text(ChangeReviewJudgment.hashWarningLabel)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.domOperacional)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(ChangeReviewJudgment.hashWarningLabel)
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
