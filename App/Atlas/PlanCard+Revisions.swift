import SwiftUI
import AtlasCore

// C19 / cena 02 — "comparar versões" só com planRevisions tipados.
// Peel forest fused cycle 019 (toggle/compare/archive/list peels).

extension PlanCard {
    @ViewBuilder
    func revisionToggle(plan: AtlasExecutionPlan) -> some View {
        let count = meaningfulRevisions.count
        revisionToggleControl(plan: plan, count: count)
        if showRevisions {
            PlanRevisionCompare(plan: plan, revisions: meaningfulRevisions)
                .transition(reduceMotion ? .identity : .opacity)
        }
    }

    func revisionToggleControl(plan: AtlasExecutionPlan, count: Int) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            withAnimation(reduceMotion ? nil : AtlasMotion.editorial) {
                showRevisions.toggle()
            }
        } label: {
            // Ação fala em sans (mono é hash/recibo/meta — canon §C).
            Text(showRevisions ? "ocultar versões" : "comparar versões · \(count)")
                .atlasSans(11, .medium).foregroundStyle(AtlasTheme.textSecondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(spokenRevisionToggle(expanded: showRevisions, count: count))
        .accessibilityHint(showRevisions ? "toque para ocultar" : "toque para expandir")
    }
}

struct PlanRevisionCompare: View {
    let plan: AtlasExecutionPlan
    let revisions: [AtlasTraceGovernance.PlanRevision]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            comparisonBody
            revisionArchiveList
        }
    }

    enum RevisionTone { case removed, added }

    struct RevisionComparison {
        let revision: AtlasTraceGovernance.PlanRevision
        let left: [String]
        let entered: [String]
        var hasChanges: Bool { !left.isEmpty || !entered.isEmpty }
    }

    var latestComparison: RevisionComparison? {
        guard let revision = revisions.last(where: { !$0.stepTitles.isEmpty }) else { return nil }
        let current = plan.steps.map(\.title)
        let archived = revision.stepTitles
        return RevisionComparison(
            revision: revision,
            left: archived.filter { !current.contains($0) },
            entered: current.filter { !archived.contains($0) }
        )
    }

    func hasArchiveMetadata(_ rev: AtlasTraceGovernance.PlanRevision) -> Bool {
        rev.reason?.isEmpty == false || rev.archivedAt != nil || !rev.stepTitles.isEmpty
    }

    func editorialArchivedAt(_ raw: String) -> String {
        if let tIndex = raw.firstIndex(of: "T") {
            return String(raw[..<tIndex])
        }
        return raw
    }

    // MARK: Compare body

    @ViewBuilder
    var comparisonBody: some View {
        if let comparison = latestComparison, comparison.hasChanges {
            VStack(alignment: .leading, spacing: 7) {
                Text("v\(comparison.revision.revision) arquivado → plano atual")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                comparisonLeftList
                comparisonEnteredList
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(comparisonAccessibilityLabel(comparison))
        }
    }

    @ViewBuilder
    var comparisonLeftList: some View {
        if let comparison = latestComparison, comparison.hasChanges, !comparison.left.isEmpty {
            revisionList(label: "saíram", items: comparison.left, tone: .removed)
        }
    }

    @ViewBuilder
    var comparisonEnteredList: some View {
        if let comparison = latestComparison, comparison.hasChanges, !comparison.entered.isEmpty {
            revisionList(label: "entraram", items: comparison.entered, tone: .added)
        }
    }

    func comparisonAccessibilityLabel(_ comparison: RevisionComparison) -> String {
        var parts = ["comparação do plano, versão \(comparison.revision.revision) arquivada"]
        if !comparison.left.isEmpty {
            parts.append("\(comparison.left.count) passos saíram")
        }
        if !comparison.entered.isEmpty {
            parts.append("\(comparison.entered.count) passos entraram")
        }
        return parts.joined(separator: ", ")
    }

    // MARK: Lists

    func revisionList(label: String, items: [String], tone: RevisionTone) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(AtlasFont.mono(9))
                .tracking(0.8)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            revisionListItems(items: items, tone: tone)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(items.count) passo\(items.count == 1 ? "" : "s")")
    }

    @ViewBuilder
    func revisionListItems(items: [String], tone: RevisionTone) -> some View {
        ForEach(items, id: \.self) { item in
            revisionBulletRow(item: item, tone: tone)
        }
    }

    func revisionBulletRow(item: String, tone: RevisionTone) -> some View {
        Text("• \(item)")
            .atlasSans(12)
            .foregroundStyle(tone == .removed ? AtlasTheme.textTertiary : AtlasTheme.textSecondary)
            .strikethrough(tone == .removed, color: AtlasTheme.textTertiary.opacity(0.7))
            .lineLimit(2)
            .accessibilityHidden(true)
    }

    // MARK: Archive

    @ViewBuilder
    var revisionArchiveList: some View {
        if revisions.contains(where: hasArchiveMetadata) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(revisions) { rev in
                    if hasArchiveMetadata(rev) {
                        revisionArchiveRow(rev)
                    }
                }
            }
        }
    }

    func revisionArchiveRow(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            revisionArchiveHeader(rev)
            revisionArchiveMeta(rev)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(revisionArchiveAccessibilityLabel(rev))
    }

    func revisionArchiveHeader(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        HStack(spacing: 6) {
            Text("v\(rev.revision) arquivado")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
            if let iteration = rev.iteration {
                Text("iter \(iteration)")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .accessibilityHidden(true)
            }
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    func revisionArchiveMeta(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        revisionArchiveReason(rev)
        revisionArchiveWhen(rev)
        revisionArchiveSteps(rev)
    }

    @ViewBuilder
    func revisionArchiveReason(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        if let reason = rev.reason, !reason.isEmpty {
            Text(rev.humanReason)
                .atlasSans(12)
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    func revisionArchiveWhen(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        if let archivedAt = rev.archivedAt {
            Text(editorialArchivedAt(archivedAt))
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    func revisionArchiveSteps(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        if !rev.stepTitles.isEmpty {
            Text(rev.stepTitles.joined(separator: " · "))
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }

    func revisionArchiveAccessibilityLabel(_ rev: AtlasTraceGovernance.PlanRevision) -> String {
        var parts = ["plano versão \(rev.revision) arquivado"]
        if let reason = rev.reason, !reason.isEmpty {
            parts.append(rev.humanReason)
        }
        if let archivedAt = rev.archivedAt {
            parts.append("em \(editorialArchivedAt(archivedAt))")
        }
        if !rev.stepTitles.isEmpty {
            parts.append("\(rev.stepTitles.count) passos")
        }
        return parts.joined(separator: ", ")
    }
}
