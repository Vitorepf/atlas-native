import SwiftUI
import AtlasCore

// WAVE-117 narrative row model

struct NarrativeRow: Identifiable, Equatable {
    enum Style { case intent, single }
    let id: String
    let style: Style
    let title: String
    let detail: String?
    let occurredAt: Date?
    var durationMs: Int? = nil
    var isP90: Bool = false
}

extension NarrativeRowView {
    var narrativeSpine: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(isCurrent ? AtlasTheme.accent : AtlasTheme.accent.opacity(0.4))
                .frame(width: 7, height: 7)
                .opacity(isCurrent && pulse && !reduceMotion ? 0.4 : 1)
                .padding(.top, 5)
            if !isLast {
                Rectangle()
                    .fill(AtlasTheme.accent.opacity(0.22))
                    .frame(width: 1.5)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 10)
        .accessibilityHidden(true)
    }
}

extension NarrativeRowView {
    var narrativeTextStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(row.title)
                .font(row.style == .intent ? .system(.footnote) : .system(.caption))
                .foregroundStyle(row.style == .intent
                    ? (isCurrent ? AtlasTheme.textPrimary : AtlasTheme.textSecondary)
                    : AtlasTheme.textTertiary)
                .lineLimit(row.style == .intent ? 3 : 2)
                .accessibilityHidden(true)
            narrativeDetailLine
            narrativeDurationMeta
        }
        .padding(.bottom, 10)
    }
}

extension NarrativeRowView {
    var currentTraits: AccessibilityTraits {
        guard isCurrent else { return [] }
        return reduceMotion ? .isSelected : [.isSelected, .updatesFrequently]
    }
}

