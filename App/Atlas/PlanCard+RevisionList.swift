import SwiftUI
import AtlasCore

// Lista de revisão — peel de PlanCard+RevisionHelpers.

extension PlanRevisionCompare {
    func revisionList(label: String, items: [String], tone: RevisionTone) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(AtlasFont.mono(9))
                .tracking(0.8)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            ForEach(items, id: \.self) { item in
                Text("• \(item)")
                    .font(.system(size: 12))
                    .foregroundStyle(tone == .removed ? AtlasTheme.textTertiary : AtlasTheme.textSecondary)
                    .strikethrough(tone == .removed, color: AtlasTheme.textTertiary.opacity(0.7))
                    .lineLimit(2)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(items.count) passo\(items.count == 1 ? "" : "s")")
    }
}
