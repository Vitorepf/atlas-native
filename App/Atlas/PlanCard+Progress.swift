import SwiftUI
import AtlasCore

// Plan progress helpers — peel de PlanCard.

extension PlanCard {
    var plan: AtlasExecutionPlan? { bubble.executionPlan }
    /// Checkpoint observado no stream; nil = nenhum passo marcado ainda (tudo pendente).
    var executionProgress: AtlasExecutionPlan.Progress? { bubble.executionProgress }
    var currentIndex: Int? { executionProgress?.current }
    var isTerminal: Bool { executionProgress?.isTerminal == true }
    var revisions: [AtlasTraceGovernance.PlanRevision] { bubble.planRevisions }
    /// Só revisões com metadata real do servidor — ausência não vira “v1” nem motivo genérico.
    var meaningfulRevisions: [AtlasTraceGovernance.PlanRevision] {
        revisions.filter { rev in
            rev.reason?.isEmpty == false || rev.archivedAt != nil || !rev.stepTitles.isEmpty
        }
    }
}
