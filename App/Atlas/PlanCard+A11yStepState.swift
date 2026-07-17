import SwiftUI
import AtlasCore

// Step state spoken — peel de PlanCard+A11yStep.

extension PlanCard {
    static func spokenStepState(_ state: StepState) -> String {
        switch state {
        case .done: "concluído"
        case .current: "em curso"
        case .pending: "pendente"
        }
    }
}
