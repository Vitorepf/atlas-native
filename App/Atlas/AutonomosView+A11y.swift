import SwiftUI
import AtlasCore

/// Spoken labels e saúde do cabeçalho — peel de AutonomosView (CICLO C residual honesty).
/// Spoken → AutonomosView+A11ySpoken.swift
/// Phase → AutonomosView+A11yPhase.swift

extension AutonomosView {
    /// Silêncio no masthead quando frota+operação estão quietas (barulho só por exceção).
    var isHeaderHealthy: Bool {
        guard case .loaded = model.phase else { return false }
        guard model.taskHealth?.incidents.present != true else { return false }
        guard AutonomosAwaitingYouSection.decisionCount(in: model.backlog) == 0 else { return false }
        let delivered = model.delivered?.deliveredTotal ?? 0
        let pending = model.backlog?.workOrders.count ?? 0
        let inbox = model.backlog?.inboxItems.count ?? 0
        guard delivered == 0, pending == 0, inbox == 0 else { return false }
        guard let fleet = model.fleet else { return false }
        return AutonomosFleetHealth.isQuiet(fleet: fleet, incidentPresent: false)
    }
}
