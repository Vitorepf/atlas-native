import SwiftUI
import AtlasCore

// Lista de revisão — peel de PlanCard+RevisionHelpers.
// Items → PlanCard+RevisionList+Items.swift

extension PlanRevisionCompare {
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
}
