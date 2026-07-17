import SwiftUI

/// Spoken labels do cabeçalho Autônomos — peel de AutonomosViewHeader.

extension AutonomosViewHeader {
    func spokenTitle(isHealthy: Bool, auditModeEnabled: Bool) -> String {
        var parts = ["Autônomos"]
        if !isHealthy { parts.append("área própria 24 horas") }
        if auditModeEnabled { parts.append("modo auditoria") }
        return parts.joined(separator: ", ")
    }

    func spokenRefreshLabel(canRefresh: Bool) -> String {
        canRefresh
            ? "atualizar instância selecionada"
            : "atualizar indisponível, selecione uma instância"
    }

    func spokenRefreshHint(canRefresh: Bool) -> String {
        canRefresh ? "recarrega estado da área selecionada" : ""
    }
}
