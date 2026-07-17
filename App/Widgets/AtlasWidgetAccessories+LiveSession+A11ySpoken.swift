import AtlasCore
import Foundation

// Spoken label da sessão viva — peel de LiveSessionWidgetA11y.
// Live → AtlasWidgetAccessories+LiveSession+A11ySpokenLive.swift

extension LiveSessionWidgetA11y {
    static func spokenLabel(
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool,
        age: String
    ) -> String {
        var parts = ["Sessão viva"]
        if let live {
            parts.append(contentsOf: spokenLiveParts(live))
        } else {
            parts.append("silêncio na obra")
            parts.append(silenceDetail(snapshot))
        }
        if stale { parts.append("visto \(age)") }
        return parts.joined(separator: ", ")
    }
}
