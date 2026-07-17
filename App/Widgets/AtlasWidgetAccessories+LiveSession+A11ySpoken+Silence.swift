import AtlasCore
import Foundation

// Silence branch — peel de LiveSessionWidgetA11y+Spoken.

extension LiveSessionWidgetA11y {
    static func spokenSilenceParts(_ snapshot: AtlasNativeSnapshot) -> [String] {
        ["silêncio na obra", silenceDetail(snapshot)]
    }
}
