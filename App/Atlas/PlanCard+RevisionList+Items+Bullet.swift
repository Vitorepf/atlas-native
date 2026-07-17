import SwiftUI
import AtlasCore

// Bullet row — peel de PlanCard+RevisionList+Items.

extension PlanRevisionCompare {
    func revisionBulletRow(item: String, tone: RevisionTone) -> some View {
        Text("• \(item)")
            .font(.system(size: 12))
            .foregroundStyle(tone == .removed ? AtlasTheme.textTertiary : AtlasTheme.textSecondary)
            .strikethrough(tone == .removed, color: AtlasTheme.textTertiary.opacity(0.7))
            .lineLimit(2)
            .accessibilityHidden(true)
    }
}
