import WidgetKit
import SwiftUI
import AtlasCore

// Retângulo do lock accessory — peel de AtlasWidgetAccessories+LockLive.
// Emphasis → AtlasWidgetAccessories+LockRectEmphasis.swift
// Branches → AtlasWidgetAccessories+LockRect+Branches.swift

extension LockAccessorySnapshotView {
    func rectangular(_ snapshot: AtlasNativeSnapshot) -> some View {
        let stale = snapshot.isStale(at: entry.date)
        let incidentLine = LockAccessoryA11y.incidentLine(snapshot.fleet?.incident)
        return VStack(alignment: .leading, spacing: 2) {
            rectangularBody(snapshot, stale: stale, incidentLine: incidentLine)
        }
        .id(LockAccessoryA11y.contentPhaseID(snapshot: snapshot, stale: stale))
        .transaction { transaction in
            if reduceMotion { transaction.disablesAnimations = true }
        }
    }
}
