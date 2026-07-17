import SwiftUI
import AtlasCore

/// Spoken labels e saúde do cabeçalho — peel de AutonomosView (CICLO C residual honesty).

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

    var contentPhaseID: String {
        switch model.phase {
        case .idle: return "idle"
        case .loading: return "loading"
        case .loaded: return "loaded"
        case .failed: return "failed"
        }
    }

    func spokenScreenLabel() -> String {
        switch model.phase {
        case .idle, .loading:
            return "Autônomos, consultando a frota"
        case .failed:
            return "Autônomos, falha ao consultar a frota"
        case .loaded:
            if isHeaderHealthy {
                return "Autônomos, frota quieta"
            }
            return "Autônomos, frota carregada"
        }
    }

    static let screenHint = "frota, digest e áreas só com dados publicados pelo servidor"
}
