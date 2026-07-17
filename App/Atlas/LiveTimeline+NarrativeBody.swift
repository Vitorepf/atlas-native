import SwiftUI
import AtlasCore

// Corpo da linha narrativa — peel de NarrativeRowView.

extension NarrativeRowView {
    var narrativeBody: some View {
        HStack(alignment: .top, spacing: 10) {
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

            VStack(alignment: .leading, spacing: 2) {
                Text(row.title)
                    .font(row.style == .intent ? .system(.footnote) : .system(.caption))
                    .foregroundStyle(row.style == .intent
                        ? (isCurrent ? AtlasTheme.textPrimary : AtlasTheme.textSecondary)
                        : AtlasTheme.textTertiary)
                    .lineLimit(row.style == .intent ? 3 : 2)
                    .accessibilityHidden(true)
                if let detail = row.detail, !detail.isEmpty {
                    Text(detail).font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(row.style == .intent ? 2 : 1)
                        .truncationMode(.middle)
                        .accessibilityHidden(true)
                }
                if let duration = row.durationMs {
                    HStack(spacing: 5) {
                        Text("Δ \(humanDuration(duration))")
                            .font(AtlasFont.mono(10))
                            .foregroundStyle(row.isP90 ? AtlasTheme.domOperacional : AtlasTheme.textTertiary)
                            .monospacedDigit()
                            .modifier(NumericTextTransition(enabled: !reduceMotion))
                        if row.isP90 {
                            Text("p90")
                                .font(AtlasFont.mono(9))
                                .foregroundStyle(AtlasTheme.domOperacional)
                        }
                    }
                    .accessibilityHidden(true)
                }
            }
            .padding(.bottom, 10)
            Spacer(minLength: 0)
        }
    }

    var currentTraits: AccessibilityTraits {
        guard isCurrent else { return [] }
        return reduceMotion ? .isSelected : [.isSelected, .updatesFrequently]
    }
}
