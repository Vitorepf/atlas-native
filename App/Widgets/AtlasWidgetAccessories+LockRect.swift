import WidgetKit
import SwiftUI
import AtlasCore

// Retângulo do lock accessory — peel de AtlasWidgetAccessories+LockLive.
// Emphasis → AtlasWidgetAccessories+LockRectEmphasis.swift

extension LockAccessorySnapshotView {
    func rectangular(_ snapshot: AtlasNativeSnapshot) -> some View {
        let stale = snapshot.isStale(at: entry.date)
        let incidentLine = LockAccessoryA11y.incidentLine(snapshot.fleet?.incident)
        return VStack(alignment: .leading, spacing: 2) {
            if let incidentLine {
                Text(incidentLine)
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .foregroundStyle(Ink.alert)
                    .lineLimit(2)
            } else if let paused = snapshot.liveSessions?.first(where: { $0.timing == .paused }) {
                Text(paused.phaseTitle)
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .foregroundStyle(Ink.alert)
                    .lineLimit(1)
                if let sub = LockAccessoryA11y.rectangularSubtitle(snapshot) {
                    Text(sub)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Ink.alert)
                }
            } else {
                Text(snapshot.liveSessions?.first?.phaseTitle ?? "silêncio na obra")
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .lineLimit(1)
                if stale {
                    Text("visto \(snapshot.ageText(at: entry.date))")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Ink.alert)
                } else if let sub = LockAccessoryA11y.rectangularSubtitle(snapshot) {
                    Text(sub)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Ink.ink2)
                }
            }
        }
        .id(LockAccessoryA11y.contentPhaseID(snapshot: snapshot, stale: stale))
        .transaction { transaction in
            if reduceMotion { transaction.disablesAnimations = true }
        }
    }
}
