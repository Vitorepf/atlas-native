import WidgetKit
import SwiftUI
import AtlasCore

// Conteúdo live/silêncio — peel de LiveSessionWidgetView.
// Bodies → AtlasWidgetAccessories+LiveSession+Bodies.swift

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionContent(snapshot: AtlasNativeSnapshot, live: AtlasNativeSnapshot.LiveSession?, stale: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("✦ Sessão viva")
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .accessibilityHidden(true)
                Spacer()
                if stale {
                    Text("visto \(snapshot.ageText(at: entry.date))")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Ink.alert)
                        .accessibilityHidden(true)
                }
            }
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
