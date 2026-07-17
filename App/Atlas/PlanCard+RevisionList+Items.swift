import SwiftUI
import AtlasCore

// Revision list items — peel de PlanCard+RevisionList.

extension PlanRevisionCompare {
    @ViewBuilder
    func revisionListItems(items: [String], tone: RevisionTone) -> some View {
        ForEach(items, id: \.self) { item in
            Text("• \(item)")
                .font(.system(size: 12))
                .foregroundStyle(tone == .removed ? AtlasTheme.textTertiary : AtlasTheme.textSecondary)
                .strikethrough(tone == .removed, color: AtlasTheme.textTertiary.opacity(0.7))
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }
}
