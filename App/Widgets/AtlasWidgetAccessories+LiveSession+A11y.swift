import AtlasCore
import Foundation

/// Spoken labels do widget Sessão viva — peel de LiveSessionWidgetView (CICLO C residual).
/// Spoken → AtlasWidgetAccessories+LiveSession+A11ySpoken.swift

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
}
