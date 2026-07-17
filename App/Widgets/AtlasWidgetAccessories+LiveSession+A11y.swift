import AtlasCore
import Foundation

/// Spoken labels do widget Sessão viva — peel de LiveSessionWidgetView (CICLO C residual).

enum LiveSessionWidgetA11y {
    static func silenceDetail(_ snapshot: AtlasNativeSnapshot) -> String {
        guard let delivery = snapshot.fleet?.lastDelivery else {
            return "nenhuma sessão viva agora"
        }
        let title = delivery.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !title.isEmpty { return "última concluída \(title)" }
        let hash = delivery.mergeHash.trimmingCharacters(in: .whitespacesAndNewlines)
        if !hash.isEmpty { return "última concluída \(String(hash.prefix(7)))" }
        return "nenhuma sessão viva agora"
    }

    static func contentPhaseID(
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool
    ) -> String {
        let title = live?.title ?? ""
        let phase = live?.phaseTitle ?? ""
        let timing = live?.timing.rawValue ?? "none"
        let delivery = snapshot.fleet?.lastDelivery?.mergeHash ?? ""
        return "\(title)|\(phase)|\(timing)|\(delivery)|\(stale)"
    }

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
