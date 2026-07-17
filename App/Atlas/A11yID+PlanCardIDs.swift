import Foundation

// Plan card A11yIDs — peel de A11yID+Execution.

extension A11yID {
    static let planCard = "plan-card"
    static let planSteps = "plan-steps"
    static let planProgress = "plan-progress"
    static let planStepPrefix = "plan-step-"
    static func planStep(_ index: Int) -> String { planStepPrefix + String(index) }
}
