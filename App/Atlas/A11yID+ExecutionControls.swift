import Foundation

// Execution control A11yIDs — peel de A11yID+Execution.

extension A11yID {
    /// Primary live-run instrument (composer strip) — WAVE-006.
    static let executionLiveStrip = "execution-live-strip"
    static let executionReconnectBanner = "execution-reconnect-banner"
    static let executionSilenceWatchdog = "execution-silence-watchdog"
    static let executionReplayScrubber = "execution-replay-scrubber"
    static let executionProof = "execution-proof"
    static let executionStateCard = "execution-state-card"
    static let executionRetry = "execution-retry"
    static let executionActionChoicePrefix = "execution-action-"
    static func executionActionChoice(_ id: String) -> String { executionActionChoicePrefix + id }
}
