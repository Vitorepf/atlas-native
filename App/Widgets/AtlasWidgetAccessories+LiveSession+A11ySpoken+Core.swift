import AtlasCore
import Foundation

// Spoken assembly — peel de LiveSessionWidgetA11y spokenLabel.
// Stale → AtlasWidgetAccessories+LiveSession+A11ySpoken+Stale.swift
// Live → AtlasWidgetAccessories+LiveSession+A11ySpoken+LiveParts.swift
// Silence → AtlasWidgetAccessories+LiveSession+A11ySpoken+SilenceParts.swift

extension LiveSessionWidgetA11y {
    static func spokenCoreParts(
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?
    ) -> [String] {
        if let live {
            return spokenLiveParts(live)
        }
        return spokenSilenceParts(snapshot)
    }
}
