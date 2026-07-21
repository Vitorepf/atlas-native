import Foundation

// WAVE-131 A11yID Arena domain

extension A11yID {
    static let arenaHomeEntry = "arena-home-entry"
    static let arenaScreen = "arena-screen"
}
extension A11yID {
    static let arenaCapabilityRowPrefix = "arena-capability-row-"
    static func arenaCapabilityRow(_ capability: String) -> String { arenaCapabilityRowPrefix + capability }
}
extension A11yID {
    static let arenaPremiumAdd = "arena-premium-add"
    static let arenaPremiumHero = "arena-premium-hero"
    static let arenaPremiumStop = "arena-premium-stop"
    static let arenaPremiumStopConfirm = "arena-premium-stop-confirm"
    static let arenaPremiumExecution = "arena-premium-execution"
    static let arenaPremiumExecutionPipeline = "arena-premium-execution-pipeline"
    static let arenaPremiumRunDetail = "arena-premium-run-detail"
    static let arenaPremiumRunDetailCases = "arena-premium-run-detail-cases"
    static let arenaPremiumPlan = "arena-premium-plan"
    static let arenaPremiumQueue = "arena-premium-queue"
    static let arenaPremiumAlerts = "arena-premium-alerts"
    static let arenaPremiumResults = "arena-premium-results"
    static let arenaPremiumFleet = "arena-premium-fleet"
    static let arenaPremiumCapabilities = "arena-premium-capabilities"
    static let arenaPremiumEnginePicker = "arena-premium-engine-picker"
    static let arenaPremiumAskPill = "arena-premium-ask-pill"

    static func arenaPremiumFleetRow(_ engine: String) -> String {
        "arena-premium-fleet-row-\(engine)"
    }
    static let arenaPremiumCapabilityDetail = "arena-premium-capability-detail"
    static let arenaPremiumExecutionAction = "arena-premium-execution-action"
    static let arenaPremiumPlanAction = "arena-premium-plan-action"
    static let arenaPremiumQueueAction = "arena-premium-queue-action"
    static let arenaPremiumAlertsAction = "arena-premium-alerts-action"
    static let arenaPremiumStopSheet = "arena-premium-stop-sheet"
    static let arenaPremiumStopActor = "arena-premium-stop-actor"
    static let arenaPremiumStopReason = "arena-premium-stop-reason"
    static let arenaPremiumStopReceipt = "arena-premium-stop-receipt"

    static func arenaPremiumTab(_ name: String) -> String {
        "arena-premium-tab-\(name)"
    }

    static func arenaPremiumState(_ phase: String) -> String {
        "arena-premium-state-\(phase)"
    }

    static func arenaPremiumPlanRow(_ suite: String) -> String {
        "arena-premium-plan-row-\(suite)"
    }

    static func arenaPremiumQueueRow(_ suite: String) -> String {
        "arena-premium-queue-row-\(suite)"
    }

    static func arenaPremiumExecutionRun(_ run: String) -> String {
        "arena-premium-execution-run-\(run)"
    }

    static func arenaPremiumResultSuite(_ suite: String) -> String {
        "arena-premium-result-suite-\(suite)"
    }
}
extension A11yID {
    static let arenaRunButton = "arena-run-button"
    static let arenaRunSheet = "arena-run-sheet"
    static let arenaRunActor = "arena-run-actor"
    static let arenaRunReason = "arena-run-reason"
    static let arenaRunSubmit = "arena-run-submit"
    static let arenaRunReceipt = "arena-run-receipt"
    static let arenaRunEnginesEmpty = "arena-run-engines-empty"
    static let arenaRunSuitesEmpty = "arena-run-suites-empty"
}
extension A11yID {
    static let arenaSuiteSheet = "arena-suite-sheet"
    static let arenaEngineSheet = "arena-engine-sheet"
}
