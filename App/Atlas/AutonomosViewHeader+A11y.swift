import SwiftUI

/// Spoken labels do cabeçalho Autônomos — peel de AutonomosViewHeader.
/// Refresh → AutonomosViewHeader+A11yRefresh.swift

extension AutonomosViewHeader {
    func spokenTitle(isHealthy: Bool, auditModeEnabled: Bool) -> String {
        var parts = [title, subtitle]
        if auditModeEnabled { parts.append("modo auditoria") }
        return parts.joined(separator: ", ")
    }

    func spokenBackLabel() -> String { "voltar" }

    func spokenBackHint() -> String { "volta" }
}
