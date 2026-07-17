import SwiftUI
import AtlasCore

// Boolean flags — peel de AutonomosDetailWorkRows+OrderFields.

extension AutonomosDetailWorkOrderFields {
    @ViewBuilder
    static func orderFieldFlags(_ item: AtlasAutonomosWorkOrder) -> some View {
        AutonomosDetailChrome.field("branch isolation", item.requiresBranchIsolation ? "sim" : "não")
        AutonomosDetailChrome.field("decisão do operador", item.operatorDecisionRequired ? "sim" : "não")
        AutonomosDetailChrome.field("evidência exigida", item.evidenceRequired ? "sim" : "não")
        AutonomosDetailChrome.field("execução feita", item.executionExecuted ? "sim" : "não")
    }
}
