import Foundation

extension A11yID {
    // M61 · Arena
    static let arenaHomeEntry = "arena-home-entry"
    static let arenaScreen = "arena-screen"
    static let arenaIndexSection = "arena-index-section"
    static let arenaCapabilitiesSection = "arena-capabilities-section"
    static let arenaCapabilityRowPrefix = "arena-capability-row-"
    static func arenaCapabilityRow(_ capability: String) -> String { arenaCapabilityRowPrefix + capability }
    static let arenaSuitesSection = "arena-suites-section"
    static let arenaNowSection = "arena-now-section"
    static let arenaNowLiveActivityNote = "arena-now-live-activity-note"
    static let arenaNowRunPrefix = "arena-now-run-"
    static func arenaNowRun(_ runId: String) -> String { arenaNowRunPrefix + runId }
    static let arenaRunButton = "arena-run-button"
    static let arenaRunSheet = "arena-run-sheet"
    static let arenaRunActor = "arena-run-actor"
    static let arenaRunReason = "arena-run-reason"
    static let arenaRunSubmit = "arena-run-submit"
    static let arenaRunReceipt = "arena-run-receipt"
    static let arenaRunEnginesEmpty = "arena-run-engines-empty"
    static let arenaRunSuitesEmpty = "arena-run-suites-empty"
    static let arenaSuiteSheet = "arena-suite-sheet"
    static let arenaEngineSheet = "arena-engine-sheet"
}
