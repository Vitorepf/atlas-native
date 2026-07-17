import WidgetKit
import SwiftUI
import AtlasCore

// Retângulo e helpers do lock accessory — peel de AtlasWidgetAccessories+LockLive.

extension LockAccessorySnapshotView {
    func rectangular(_ snapshot: AtlasNativeSnapshot) -> some View {
        let stale = snapshot.isStale(at: entry.date)
        let attention = hasAttention(snapshot)
        let incident = snapshot.fleet?.incident
        return VStack(alignment: .leading, spacing: 2) {
            if let incident, incident.present {
                Text(incident.recommendedAction ?? incident.flags.first ?? "incidente na frota")
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .foregroundStyle(Ink.alert)
                    .lineLimit(2)
            } else if attention, let paused = snapshot.liveSessions?.first(where: { $0.timing == .paused }) {
                Text(paused.phaseTitle)
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .foregroundStyle(Ink.alert)
                    .lineLimit(1)
                Text("‖ atenção")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Ink.alert)
            } else {
                Text(snapshot.liveSessions?.first?.phaseTitle ?? "silêncio na obra")
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .lineLimit(1)
                Text(stale ? "visto \(snapshot.ageText(at: entry.date))" : rectangularSubtitle(snapshot))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(stale ? Ink.alert : Ink.ink2)
            }
        }
    }

    func rectangularSubtitle(_ snapshot: AtlasNativeSnapshot) -> String {
        guard let sessions = snapshot.liveSessions, let first = sessions.first else {
            return "nenhuma sessão viva agora"
        }
        if first.timing == .paused { return "‖ pausado" }
        if let ms = first.elapsedActiveMs {
            return "\(sessions.count) · \(AtlasTime.formatActiveDuration(milliseconds: ms))"
        }
        return "\(sessions.count) sessões vivas"
    }

    func inlineText(_ snapshot: AtlasNativeSnapshot) -> String {
        if snapshot.fleet?.incident?.present == true {
            return "Atlas · frota · incidente"
        }
        if hasAttention(snapshot) {
            return "Atlas · atenção"
        }
        let n = snapshot.liveSessions?.count ?? 0
        if n == 0 { return "Atlas · silêncio" }
        return "Atlas · \(n) executando"
    }

    func emphasisColor(_ snapshot: AtlasNativeSnapshot) -> Color {
        if snapshot.fleet?.incident?.present == true || hasAttention(snapshot) {
            return Ink.alert
        }
        return Ink.ink
    }

    func hasAttention(_ snapshot: AtlasNativeSnapshot) -> Bool {
        snapshot.liveSessions?.contains {
            $0.timing == .paused
                || $0.phaseTitle.localizedCaseInsensitiveContains("atenção")
                || $0.phaseTitle.localizedCaseInsensitiveContains("aguard")
        } == true
    }
}
