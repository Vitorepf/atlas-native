import WidgetKit
import SwiftUI
import AtlasCore

// Conteúdo live/silêncio — peel de LiveSessionWidgetView.

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
                Text(live.title)
                    .font(.system(size: 17, weight: .semibold, design: .serif))
                    .foregroundStyle(Ink.ink)
                    .lineLimit(1)
                    .accessibilityHidden(true)
                Text(live.phaseTitle)
                    .font(.system(size: 14, design: .serif))
                    .italic()
                    .foregroundStyle(live.timing == .paused ? Ink.gold : Ink.ink2)
                    .lineLimit(1)
                    .accessibilityHidden(true)
                HStack {
                    LiveSessionWidgetTimer(live: live)
                    Spacer()
                    Text("Seguir")
                        .font(.system(size: 12, weight: .semibold, design: .serif))
                        .foregroundStyle(Ink.bg)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Ink.gold))
                        .accessibilityHidden(true)
                }
            } else {
                Text("silêncio na obra")
                    .font(.system(size: 17, weight: .semibold, design: .serif))
                    .accessibilityHidden(true)
                Text(LiveSessionWidgetA11y.silenceDetail(snapshot))
                    .font(.system(size: 12, design: .serif))
                    .foregroundStyle(Ink.ink2)
                    .accessibilityHidden(true)
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
