import AtlasCore
import Foundation

// Spoken label da sessão viva — peel de LiveSessionWidgetA11y.
// Stale → AtlasWidgetAccessories+LiveSession+A11ySpoken+Stale.swift

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
            parts.append(contentsOf: spokenSilenceParts(snapshot))
        }
        parts.append(contentsOf: spokenStaleParts(stale: stale, age: age))
        return parts.joined(separator: ", ")
    }
}
