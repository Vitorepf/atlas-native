import SwiftUI
import AtlasCore

// Step state helper — peel de PlanCard+Steps.

extension PlanCard {
    func stepState(_ idx: Int) -> StepState {
        guard let c = currentIndex else { return .pending }
        if isTerminal { return .done }
        if idx + 1 < c { return .done }
        if idx + 1 == c { return .current }
        return .pending
    }
}
