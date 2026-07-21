import Foundation

// IDLE-COMPRESS fused

enum A11yID {
    static let topbarCode = "topbar-code"
    static let auditMasthead = "audit-masthead"
    static let conversationScreen = "conversation-screen"
    static let conversationInput = "conversation-input"
    static let conversationSend = "conversation-send"
    static let conversationOptions = "conversation-options"
    static let conversationToast = "conversation-toast"
    static let conversationOutline = "conversation-outline"
    static let conversationOutlineSheet = "conversation-outline-sheet"
    static let conversationStaleReadSeal = "conversation-stale-read-seal"
    static let conversationHeaderContinuity = "conversation-header-continuity"
    static let composerAttachmentStrip = "composer-attachment-strip"
    static let conversationNewMarker = "conversation-new-marker"
    static let conversationOutlineRowPrefix = "conversation-outline-row-"
    static let conversationLoadFailure = "conversation-load-failure"
    static let conversationScrollFAB = "conversation-scroll-fab"
    static let continuityHandoffReceipt = "continuity-handoff-receipt"
}

extension A11yID {
    static let cameraPicker = "composer-camera-picker"
    static let attachmentsSheet = "composer-attachments-sheet"
    static let attachmentPhoto = "composer-attachment-photo"
    static let attachmentFile = "composer-attachment-file"
    static let attachmentPaste = "composer-attachment-paste"
}
extension A11yID {
    static let draftPrefix = "composer-draft-"
    static let draftRemovePrefix = "composer-draft-remove-"
    static func draft(_ id: String) -> String { draftPrefix + id }
    static func draftRemove(_ id: String) -> String { draftRemovePrefix + id }
}
extension A11yID {
    static let modeSheet = "composer-mode-sheet"
    static let effortSheet = "composer-effort-sheet"
    static let modeRowPrefix = "composer-mode-row-"
    static let effortRowPrefix = "composer-effort-row-"
    static func modeRow(_ key: String) -> String { modeRowPrefix + key }
    static func effortRow(_ effort: String) -> String { effortRowPrefix + effort }
}
extension A11yID {
    static let steerSheet = "steer-sheet"
    static let steerInstruction = "steer-instruction"
    static let steerScope = "steer-scope"
    static let steerSubmit = "steer-submit"
    static let steerReceipt = "steer-receipt"
}
extension A11yID {
    static let workspaceSheet = "composer-workspace-sheet"
    static let workspaceRowPrefix = "composer-workspace-row-"
    static func workspaceRow(_ key: String) -> String { workspaceRowPrefix + key }
}
extension A11yID {
    static func conversationOutlineRow(_ index: Int) -> String { conversationOutlineRowPrefix + String(index) }
}
extension A11yID {
    static let editorialTurnSignature = "editorial-turn-signature"
    static let editorialTurnFeedbackPrefix = "editorial-turn-feedback-"
    static func editorialTurnFeedback(_ kind: String) -> String { editorialTurnFeedbackPrefix + kind }
}
extension A11yID {
    static let executionLiveStrip = "execution-live-strip"
    static let executionAgentLanes = "execution-agent-lanes"
    static let executionReconnectBanner = "execution-reconnect-banner"
    static let executionSilenceWatchdog = "execution-silence-watchdog"
    static let executionReplayScrubber = "execution-replay-scrubber"
    static let executionProof = "execution-proof"
    static let executionStateCard = "execution-state-card"
    static let executionRetry = "execution-retry"
    static let executionActionChoicePrefix = "execution-action-"
    static func executionActionChoice(_ id: String) -> String { executionActionChoicePrefix + id }
}
extension A11yID {
    static let topbarSearch = "topbar-search"
    static let topbarProfile = "topbar-profile"
    static let profileSheet = "profile-sheet"
    static let profileAuditToggle = "profile-audit-toggle"
    static let homeAddWorkspace = "home-add-workspace"
    static let workspacePickerSheet = "workspace-picker-sheet"
    static let workspacePickerRowPrefix = "workspace-picker-"
    static func workspacePickerRow(_ slug: String) -> String { workspacePickerRowPrefix + slug }
    static let workspacePickerNoRepo = "workspace-picker-no-repo"
    static let homeInputPill = "home-input-pill"
    static let homeLoading = "home-loading"
    static let homeOffline = "home-offline"
    static let homeRetry = "home-retry"
}
extension A11yID {
    static let homeWorkspacePrefix = "home-workspace-"
    static func homeWorkspace(_ key: String) -> String { homeWorkspacePrefix + key }
}
extension A11yID {
    static let liveNowSection = "live-now-section"
    static let liveNowRowPrefix = "live-now-row-"
    static let liveNowRemoteBadgePrefix = "live-now-remote-badge-"
    static func liveNowRow(_ index: Int) -> String { liveNowRowPrefix + String(index) }
    static func liveNowRemoteBadge(_ index: Int) -> String { liveNowRemoteBadgePrefix + String(index) }
}
extension A11yID {
    static let liveTimeline = "live-timeline"
    static let liveTimelineFace = "live-timeline-face"
    static let liveTimelineFilters = "live-timeline-filters"
    static let liveTimelineFilterSilence = "live-timeline-filter-silence"
    static let liveTimelineFilterPrefix = "live-timeline-filter-"
    static func liveTimelineFilter(_ raw: String) -> String { liveTimelineFilterPrefix + raw }
}
extension A11yID {
    static let nightlyProposalCard = "nightly-proposal-card"
    static let nightlyProposalAccept = "nightly-proposal-accept"
    static let nightlyProposalDismiss = "nightly-proposal-dismiss"
    static let nightlyProposalMute = "nightly-proposal-mute"

    static let selfReceiptSheet = "self-receipt-sheet"
    static let selfReceiptVeto = "self-receipt-veto"
}
extension A11yID {
    static let planCard = "plan-card"
    static let planDetailToggle = "plan-detail-toggle"
    static let planSteps = "plan-steps"
    static let planProgress = "plan-progress"
    static let planFace = "plan-face"
    static let planStepPrefix = "plan-step-"
    static func planStep(_ index: Int) -> String { planStepPrefix + String(index) }
}
extension A11yID {
    static let queueChip = "queue-chip"
    static let queueSheet = "queue-sheet"
    static let queueRowPrefix = "queue-row-"
    static let queuePromotePrefix = "queue-promote-"
    static let queueRemovePrefix = "queue-remove-"
    static func queueRow(_ index: Int) -> String { queueRowPrefix + String(index) }
    static func queuePromote(_ id: String) -> String { queuePromotePrefix + id }
    static func queueRemove(_ id: String) -> String { queueRemovePrefix + id }
}
extension A11yID {
    static let searchScreen = "search-screen"
    static let searchField = "search-field"
    static let searchClear = "search-clear"
    static let searchRecentCaption = "search-recent-caption"
    static let searchResultsCaption = "search-results-caption"
    static let searchEmpty = "search-empty"
    static let searchLoading = "search-loading"
    static let searchOffline = "search-offline"
    static let searchResultPrefix = "search-result-"

    static func searchResult(_ threadId: String) -> String { searchResultPrefix + threadId }
}
extension A11yID {
    static let workspaceScreen = "workspace-screen"
    static let workspaceEmpty = "workspace-empty"
    static let workspaceLoading = "workspace-loading"
    static let workspaceOffline = "workspace-offline"
    static let workspaceRetry = "workspace-retry"
    static let workspaceThreadsCaption = "workspace-threads-caption"
    static let workspaceThreadPrefix = "workspace-thread-"
    static let workspaceAreaFilter = "workspace-area-filter"
    static let workspaceNewPill = "workspace-new-pill"

    static func workspaceThread(_ threadId: String) -> String { workspaceThreadPrefix + threadId }
}
