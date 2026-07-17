import SwiftUI
import AtlasCore

// Corpo da linha narrativa — peel de NarrativeRowView.
// Meta → +NarrativeMeta · Spine → +NarrativeSpine.swift

extension NarrativeRowView {
    var narrativeBody: some View {
        HStack(alignment: .top, spacing: 10) {
            narrativeSpine

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
                narrativeDurationMeta
            }
            .padding(.bottom, 10)
            Spacer(minLength: 0)
        }
    }
}
