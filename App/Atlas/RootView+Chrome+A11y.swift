import SwiftUI

/// Spoken labels do chrome da home — peel de RootView+Chrome (CICLO C residual honesty).
/// Home → RootView+Chrome+A11yHome.swift

extension RootView {
    func mastheadSpokenLabel(auditModeEnabled: Bool) -> String {
        auditModeEnabled ? "Atlas, modo auditoria" : "Atlas"
    }

    func mastheadSpokenHint() -> String {
        "pressione e segure para alternar modo auditoria"
    }
}
