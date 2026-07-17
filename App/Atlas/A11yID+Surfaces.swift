import Foundation

extension A11yID {
    // M61 · Arena
    static let arenaHomeEntry = "arena-home-entry"
    static let arenaScreen = "arena-screen"
    static let arenaIndexSection = "arena-index-section"
    static let arenaCapabilitiesSection = "arena-capabilities-section"
    static let arenaSuitesSection = "arena-suites-section"
    static let arenaNowSection = "arena-now-section"
    static let arenaRunButton = "arena-run-button"
    static let arenaRunSheet = "arena-run-sheet"
    static let arenaRunActor = "arena-run-actor"
    static let arenaRunReason = "arena-run-reason"
    static let arenaRunSubmit = "arena-run-submit"
    static let arenaRunReceipt = "arena-run-receipt"
    static let arenaSuiteSheet = "arena-suite-sheet"
    static let arenaEngineSheet = "arena-engine-sheet"

    // C15 · Change review (cena 12)
    static let reviewGovernance = "review-governance"
    static let reviewSheet = "review-sheet"
    static let reviewUnavailable = "review-unavailable"
    static let reviewEmpty = "review-empty"
    static let reviewLoadFailure = "review-load-failure"
    static let reviewDiffUnavailable = "review-diff-unavailable"
    static let reviewFindingsSection = "review-findings-section"
    static let reviewFindingAxisPrefix = "review-finding-axis-"
    static let reviewFindingRowPrefix = "review-finding-row-"
    static func reviewFindingAxis(_ axis: String) -> String { reviewFindingAxisPrefix + axis.lowercased() }
    static func reviewFindingRow(_ id: String) -> String { reviewFindingRowPrefix + id }

    // V4 · Artifacts & Proof
    static let artifactsRow = "artifacts-row"
    static let artifactsSheet = "artifacts-sheet"
    static let artifactsEmpty = "artifacts-empty"
    static let artifactsUnavailable = "artifacts-unavailable"
    static let artifactsLoadFailure = "artifacts-load-failure"
    static let artifactsItemPrefix = "artifacts-item-"
    static func artifactsItem(_ index: Int) -> String { artifactsItemPrefix + String(index) }

    // M07 · Steering
    static let steerSheet = "steer-sheet"
    static let steerInstruction = "steer-instruction"
    static let steerScope = "steer-scope"
    static let steerSubmit = "steer-submit"
    static let steerReceipt = "steer-receipt"
}
