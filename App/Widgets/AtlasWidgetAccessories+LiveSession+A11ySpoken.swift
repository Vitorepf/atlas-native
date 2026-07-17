import AtlasCore
import Foundation

// Spoken label da sessão viva — peel de LiveSessionWidgetA11y.

extension LiveSessionWidgetA11y {
    static func spokenLabel(
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool,
        age: String
    ) -> String {
        var parts = ["Sessão viva"]
        if let live {
            parts.append("\(live.title), \(live.phaseTitle)")
            if live.timing == .paused {
                parts.append("pausado")
                if let clock = LockAccessoryA11y.frozenClock(live) {
                    parts.append("tempo congelado \(clock)")
                }
            } else {
                parts.append("em execução")
            }
        } else {
            parts.append("silêncio na obra")
            parts.append(silenceDetail(snapshot))
        }
        if stale { parts.append("visto \(age)") }
        return parts.joined(separator: ", ")
    }
}
