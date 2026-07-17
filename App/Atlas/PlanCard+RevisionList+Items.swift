import SwiftUI
import AtlasCore

// Revision list items — peel de PlanCard+RevisionList.
// Bullet → PlanCard+RevisionList+Items+Bullet.swift

extension PlanRevisionCompare {
    @ViewBuilder
    func revisionListItems(items: [String], tone: RevisionTone) -> some View {
        ForEach(items, id: \.self) { item in
            revisionBulletRow(item: item, tone: tone)
        }
    }
}
