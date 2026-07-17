import WidgetKit
import SwiftUI
import AtlasCore

// Conteúdo live/silêncio — peel de LiveSessionWidgetView.
// Bodies → AtlasWidgetAccessories+LiveSession+Bodies.swift
// Header → AtlasWidgetAccessories+LiveSession+Header.swift

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionContent(snapshot: AtlasNativeSnapshot, live: AtlasNativeSnapshot.LiveSession?, stale: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            liveSessionHeader(stale: stale, age: snapshot.ageText(at: entry.date))
            if let live {
                liveSessionActiveBody(live)
            } else {
                liveSessionSilenceBody(snapshot)
            }
        }
        .id(LiveSessionWidgetA11y.contentPhaseID(snapshot: snapshot, live: live, stale: stale))
        .transaction { transaction in
            if reduceMotion { transaction.disablesAnimations = true }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(LiveSessionWidgetA11y.spokenLabel(
            snapshot: snapshot,
            live: live,
            stale: stale,
            age: snapshot.ageText(at: entry.date)
        ))
    }
}
