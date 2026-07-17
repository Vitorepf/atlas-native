import SwiftUI
import AtlasCore

// A11y label — peel de ExecutingStrip (régua ≤100).

extension ExecutingStrip {
    var stripAccessibilityLabel: String {
        if bubble.showsReconnectSurface {
            return bubble.reconnectSpokenLabel
        }
        if let p = bubble.executionProgress {
            return "execução ao vivo, passo \(p.current) de \(p.total), \(p.title)"
        }
        if let act = bubble.currentActivity {
            return "execução ao vivo, \(act.title), \(bubble.activities.count) eventos"
        }
        return "seguindo a execução, \(bubble.activities.count) eventos"
    }
}
