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

    // C15/C21 · Change review (cenas 07 + 12)
    static let reviewGovernance = "review-governance"
    static let reviewCouncil = "review-council"
    static let reviewCouncilMemberPrefix = "review-council-member-"
    static func reviewCouncilMember(_ provider: String) -> String {
        reviewCouncilMemberPrefix + provider.lowercased()
    }
    static let reviewSheet = "review-sheet"
    static let reviewChipPrefix = "review-chip-"
    static func reviewChip(_ traceId: String) -> String { reviewChipPrefix + traceId }
    static let reviewUnavailable = "review-unavailable"
    static let reviewEmpty = "review-empty"
    static let reviewLoadFailure = "review-load-failure"
    static let reviewDiffUnavailable = "review-diff-unavailable"
    static let reviewFindingsSection = "review-findings-section"
    static let reviewFindingAxisPrefix = "review-finding-axis-"
    static let reviewFindingRowPrefix = "review-finding-row-"
    static let reviewHashWarning = "review-hash-warning"
    static let reviewRunHeader = "review-run-header"
    static let reviewToast = "review-toast"
    static let reviewControlsSection = "review-controls-section"
    static let reviewTestsSection = "review-tests-section"
    static let reviewDecidedSection = "review-decided-section"
    static let reviewRunAccept = "review-run-accept"
    static let reviewRunReject = "review-run-reject"
    static let reviewPatchCardPrefix = "review-patch-card-"
    static let reviewPatchDiffPrefix = "review-patch-diff-"
    static let reviewFileRowPrefix = "review-file-row-"
    static let reviewFileAcceptPrefix = "review-file-accept-"
    static let reviewFileRejectPrefix = "review-file-reject-"
    static func reviewFindingAxis(_ axis: String) -> String { reviewFindingAxisPrefix + axis.lowercased() }
    static func reviewFindingRow(_ id: String) -> String { reviewFindingRowPrefix + id }
    static func reviewPatchCard(_ patchId: String) -> String { reviewPatchCardPrefix + patchId }
    static func reviewPatchDiff(_ patchId: String) -> String { reviewPatchDiffPrefix + patchId }
    private static func reviewFileKey(patchId: String, filePath: String) -> String {
        patchId + "-" + filePath.replacingOccurrences(of: "/", with: "--")
    }
    static func reviewFileRow(patchId: String, filePath: String) -> String {
        reviewFileRowPrefix + reviewFileKey(patchId: patchId, filePath: filePath)
    }
    static func reviewFileAccept(patchId: String, filePath: String) -> String {
        reviewFileAcceptPrefix + reviewFileKey(patchId: patchId, filePath: filePath)
    }
    static func reviewFileReject(patchId: String, filePath: String) -> String {
        reviewFileRejectPrefix + reviewFileKey(patchId: patchId, filePath: filePath)
    }

    // V4 · Artifacts & Proof
    static let artifactsRow = "artifacts-row"
    static let artifactsSheet = "artifacts-sheet"
    static let artifactsEmpty = "artifacts-empty"
    static let artifactsUnavailable = "artifacts-unavailable"
    static let artifactsLoadFailure = "artifacts-load-failure"
    static let artifactsMount = "artifacts-mount"
    static let artifactsMountCheckPrefix = "artifacts-mount-check-"
    static func artifactsMountCheck(_ index: Int) -> String { artifactsMountCheckPrefix + String(index) }
    static let artifactsItemPrefix = "artifacts-item-"
    static func artifactsItem(_ index: Int) -> String { artifactsItemPrefix + String(index) }
    static let artifactsZoomImage = "artifacts-zoom-image"

    // C5 · Live orchestration timeline
    static let liveTimeline = "live-timeline"
    static let liveTimelineFilters = "live-timeline-filters"
    static let liveTimelineFilterSilence = "live-timeline-filter-silence"
    static let liveTimelineFilterPrefix = "live-timeline-filter-"
    static func liveTimelineFilter(_ raw: String) -> String { liveTimelineFilterPrefix + raw }

    // M07 · Steering
    static let steerSheet = "steer-sheet"
    static let steerInstruction = "steer-instruction"
    static let steerScope = "steer-scope"
    static let steerSubmit = "steer-submit"
    static let steerReceipt = "steer-receipt"
}
