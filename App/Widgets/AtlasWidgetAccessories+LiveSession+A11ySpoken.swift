import AtlasCore
import Foundation

// Spoken label da sessão viva — peel de LiveSessionWidgetA11y.
// Stale → AtlasWidgetAccessories+LiveSession+A11ySpoken+Stale.swift
// Core → AtlasWidgetAccessories+LiveSession+A11ySpoken+Core.swift

extension LiveSessionWidgetA11y {
    static func spokenLabel(
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool,
        age: String
    ) -> String {
        var parts = ["Sessão viva"]
        parts.append(contentsOf: spokenCoreParts(snapshot: snapshot, live: live))
        parts.append(contentsOf: spokenStaleParts(stale: stale, age: age))
        return parts.joined(separator: ", ")
    }
}
