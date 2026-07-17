import SwiftUI

/// Spoken labels do Session Hub — peel de LiveNowSection (CICLO C residual honesty).

extension LiveNowSection {
    static func spokenSectionLabel(isHub: Bool, count: Int, remoteCount: Int) -> String {
        guard isHub else { return "vivo agora" }
        var label = "vivo agora, \(count) sessões vivas"
        if remoteCount > 0 {
            label += ", \(remoteCount) remota\(remoteCount == 1 ? "" : "s") em outra superfície"
        }
        return label
    }
}
