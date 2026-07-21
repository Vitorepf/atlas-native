import AtlasCore
import SwiftUI

// Cycle 041 fuse → ExecutingStrip+A11y.swift

extension ExecutingStrip {
    var stripAccessibilityLabel: String {
        var parts: [String] = []
        if bubble.showsReconnectSurface {
            parts.append(bubble.reconnectSpokenLabel)
        } else if let p = bubble.executionProgress {
            parts.append("execução ao vivo, passo \(p.current) de \(p.total), \(p.title)")
        } else if let act = bubble.currentActivity {
            parts.append("execução ao vivo, \(act.title)")
        } else {
            parts.append("seguindo a execução")
        }
        parts.append(contentsOf: stripAccessibilityExtras())
        return parts.joined(separator: ", ")
    }
}
