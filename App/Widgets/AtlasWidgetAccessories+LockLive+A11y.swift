import AtlasCore
import Foundation

/// Spoken labels do lock accessory — peel de LockAccessorySnapshotView (CICLO C residual).
/// Spoken label → AtlasWidgetAccessories+LockLive+Spoken.swift

enum LockAccessoryA11y {
    static func hasAttention(_ snapshot: AtlasNativeSnapshot) -> Bool {
        snapshot.liveSessions?.contains { $0.timing == .paused } == true
    }

    /// Só texto publicado pelo Core — nunca «incidente na frota» fabricado.
    static func incidentLine(_ incident: AtlasNativeSnapshot.Fleet.Incident?) -> String? {
        guard let incident, incident.present else { return nil }
        if let action = incident.recommendedAction?
            .trimmingCharacters(in: .whitespacesAndNewlines), !action.isEmpty {
            return action
        }
        if let flag = incident.flags.lazy
            .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            .first(where: { !$0.isEmpty }) {
            return flag
        }
        return nil
    }

    static func frozenClock(_ session: AtlasNativeSnapshot.LiveSession) -> String? {
        guard session.timing == .paused, let ms = session.elapsedActiveMs else { return nil }
        return AtlasTime.formatActiveDuration(milliseconds: ms)
    }

    /// Subtítulo retangular: timer só em pausa; sessão única saudável fica quieta.
    static func rectangularSubtitle(_ snapshot: AtlasNativeSnapshot) -> String? {
        guard let sessions = snapshot.liveSessions, let first = sessions.first else {
            return "nenhuma sessão viva agora"
        }
        if first.timing == .paused {
            if let clock = frozenClock(first) { return "‖ \(clock)" }
            return "‖ pausado"
        }
        if sessions.count > 1 { return "\(sessions.count) sessões vivas" }
        return nil
    }

    static func inlineText(_ snapshot: AtlasNativeSnapshot) -> String {
        if LockAccessoryA11y.incidentLine(snapshot.fleet?.incident) != nil {
            return "Atlas · frota"
        }
        if hasAttention(snapshot) { return "Atlas · pausado" }
        let n = snapshot.liveSessions?.count ?? 0
        if n == 0 { return "Atlas · silêncio" }
        return "Atlas · \(n) executando"
    }

    static func contentPhaseID(snapshot: AtlasNativeSnapshot, stale: Bool) -> String {
        let incident = incidentLine(snapshot.fleet?.incident) ?? ""
        let paused = hasAttention(snapshot) ? "p" : "r"
        let n = snapshot.liveSessions?.count ?? 0
        let phase = snapshot.liveSessions?.first?.phaseTitle ?? ""
        return "\(incident)|\(paused)|\(n)|\(phase)|\(stale)"
    }
}
