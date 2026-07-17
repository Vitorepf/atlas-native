import AtlasCore
import Foundation

/// Inline text / phase ID — peel de LockLive+A11yInline.

extension LockAccessoryA11y {
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
