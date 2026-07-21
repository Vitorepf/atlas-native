import AtlasCore
import Foundation
import SwiftUI

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
        expanded ? "diff expandido" : "diff recolhido"
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
        return "alertas \(flags.joined(separator: ", "))"
    }

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
    func patchCardChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .atlasCard()
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
            Text("PATCH \(String(patch.id.prefix(8)))")
                .font(AtlasFont.mono(10)).tracking(0.8).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer()
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                toggleDiff()
            } label: {
                Text(diffExpanded ? "Fechar diff" : "Ver diff")
                    .font(.system(.footnote, weight: .medium))
                    .foregroundStyle(AtlasTheme.accent)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel(ChangeReviewPatchA11y.spokenDiffToggle(expanded: diffExpanded))
            .accessibilityHint("mostra ou oculta o conteúdo do diff para este patch")
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
