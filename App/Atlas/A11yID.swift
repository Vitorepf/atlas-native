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

extension A11yID {
    static let artifactsRow = "artifacts-row"
    static let artifactsSheet = "artifacts-sheet"
    static let artifactsFace = "artifacts-face"
    static let artifactsEmpty = "artifacts-empty"
    static let artifactsUnavailable = "artifacts-unavailable"
    static let artifactsLoadFailure = "artifacts-load-failure"
    static let artifactsMount = "artifacts-mount"
    static let artifactsMountCheckPrefix = "artifacts-mount-check-"
    static func artifactsMountCheck(_ index: Int) -> String { artifactsMountCheckPrefix + String(index) }
    static let artifactsItemPrefix = "artifacts-item-"
    static func artifactsItem(_ index: Int) -> String { artifactsItemPrefix + String(index) }
    static let artifactsZoomImage = "artifacts-zoom-image"
}

extension A11yID {
    static let autonomosScreen = "autonomos-screen"
    static let autonomosAwaitingYou = "autonomos-awaiting-you"
    static let autonomosDetailSheet = "autonomos-detail-sheet"
    static let autonomosDetailButtonPrefix = "autonomos-detail-button-"
    static let autonomosRhythmLine = "autonomos-rhythm-line"
    static let autonomosRhythmSheet = "autonomos-rhythm-sheet"
    static let autonomosGovernedToggle = "autonomos-governed-toggle"
    static let autonomosOperationToggle = "autonomos-operation-toggle"
    static let autonomosRhythmUnmute = "autonomos-rhythm-unmute"
    static let autonomosHub = "autonomos-hub"
    static let autonomosList = "autonomos-list"
    static let autonomosNew = "autonomos-new"
    static let autonomosEvolution = "autonomos-evolution"
    static let autonomosDecisions = "autonomos-decisions"
    static let autonomosDecision = "autonomos-decision"
    static let autonomosAreaMap = "autonomos-area-map"
    static let autonomosFleetMap = "autonomos-fleet-map"
    static let autonomosCycle = "autonomos-cycle"
    static let autonomosIncident = "autonomos-incident"
    static let autonomosAskPill = "autonomos-ask-pill"
    static let autonomosAreasSheet = "autonomos-areas-sheet"
    static let autonomosGovernanceSheet = "autonomos-governance-sheet"
    static let autonomosReasonSheet = "autonomos-reason-sheet"
    static let autonomosReasonActor = "autonomos-reason-actor"
    static let autonomosReasonField = "autonomos-reason-field"
    static let autonomosReasonSubmit = "autonomos-reason-submit"
}

extension A11yID {
    static let autonomosHeader = "autonomos-header"
    static let autonomosBack = "autonomos-back"
    static let autonomosRefresh = "autonomos-refresh"
    static let autonomosStartRunReceipt = "autonomos-start-run-receipt"
    static let autonomosControlReceipt = "autonomos-control-receipt"
    static let autonomosControlError = "autonomos-control-error"
}

extension A11yID {
    static let autonomosTaskHealthQuiet = "autonomos-task-health-quiet"
    static let autonomosTaskHealthIncident = "autonomos-task-health-incident"
    static let autonomosLoadFailure = "autonomos-load-failure"
    static let autonomosRetry = "autonomos-retry"
}

extension A11yID {
    static let codeStatus = "code-status"
    static let codeRepoSwitcher = "code-repo-switcher"
    static let codeRepoPicker = "code-repo-picker"
    static let codeRepoPickerRowPrefix = "code-repo-picker-row-"
    static let codeGraphTruncated = "code-graph-truncated"
    static let codeGraphFilters = "code-graph-filters"
    static let codeGraphWorktrees = "code-graph-worktrees"
    static let codeGraphFilterPrefix = "code-graph-filter-"
}

extension A11yID {
    static func codeCommit(hashPrefix: String) -> String { codeCommitPrefix + hashPrefix }
    static func codeGraphFilter(_ raw: String) -> String { codeGraphFilterPrefix + raw }
}

extension A11yID {
    static let codeHealReceipt = "code-heal-receipt"
    static let codeHealReceiptSheet = "code-heal-receipt-sheet"
    static let codeHealStepPrefix = "code-heal-step-"
    static let codeHealUndoWindow = "code-heal-undo-window"
    static let codeHealUndo = "code-heal-undo"
    static let codeHealUndoError = "code-heal-undo-error"
}

extension A11yID {
    static func codeHealStep(_ index: Int) -> String { codeHealStepPrefix + String(index) }
    static func whyRow(_ index: Int) -> String { whyRowPrefix + String(index) }
    static func whyFileRow(_ index: Int) -> String { whyFileRowPrefix + String(index) }
}

extension A11yID {
    static func codeRepoPickerRow(_ slug: String) -> String {
        codeRepoPickerRowPrefix + slug
    }
}

extension A11yID {
    static let codeAskAnchorNote = "code-ask-anchor-note"
    static let codeAskClear = "code-ask-clear"
    static let codeAskPill = "code-ask-pill"
    static let codeProvenanceLaw = "code-provenance-law"
    static let codeProvenanceAsk = "code-provenance-ask"
    static let codeProvenanceState = "code-provenance-state"
    static let codeCommitBody = "code-commit-body"
    static let codeCommitFiles = "code-commit-files"
    static let whySheet = "why-sheet"
    static let whyRowPrefix = "why-row-"
    static let whyFileRowPrefix = "why-file-row-"
    static let codeMirror = "code-mirror"
    static let codeWeek = "code-week"
    static let codeRepoHealth = "code-repo-health"
}

extension A11yID {
    static let radarScreen = "code-radar"
    static let codeScreen = "code-screen"
    static let radarLoading = "code-radar-loading"
    static let radarFailure = "code-radar-failure"
    static let codeLoadFailure = "code-load-failure"
    static let codeLoadRetry = "code-load-retry"
    static let radarStatus = "radar-status"
    static let radarRecents = "radar-recents"
    static let radarFolders = "radar-folders"
    static let radarLoose = "radar-loose"
    static let radarRepoPrefix = "radar-repo-"
    static let radarFolderPrefix = "radar-folder-"
    static let codeCommitPrefix = "code-commit-"
    static let radarAskPill = "code-radar-ask-pill"
}

extension A11yID {
    static func radarRepo(_ slug: String) -> String { radarRepoPrefix + slug }
    static func radarFolder(_ slug: String) -> String { radarFolderPrefix + slug }
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
    static let homeConversasSection = "home-conversas-section"
    static let homeOperacaoSection = "home-operacao-section"
    static let homeWorkspacesSection = "home-workspaces-section"
    static let homeConversasEntry = "home-conversas-entry"
    static let homeAutonomosEntry = "home-autonomos-entry"
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
    static let markdownCodeBlockPrefix = "markdown-code-block-"
    static let markdownCodeCopyPrefix = "markdown-code-copy-"
    static func markdownCodeBlock(_ index: Int) -> String { markdownCodeBlockPrefix + String(index) }
    static func markdownCodeCopy(_ index: Int) -> String { markdownCodeCopyPrefix + String(index) }
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
    static let reviewCouncil = "review-council"
    static let reviewCouncilMemberPrefix = "review-council-member-"
    static func reviewCouncilMember(_ provider: String) -> String {
        reviewCouncilMemberPrefix + provider.lowercased()
    }
}

extension A11yID {
    static func reviewFileAccept(patchId: String, filePath: String) -> String {
        reviewFileAcceptPrefix + reviewFileKey(patchId: patchId, filePath: filePath)
    }
    static func reviewFileReject(patchId: String, filePath: String) -> String {
        reviewFileRejectPrefix + reviewFileKey(patchId: patchId, filePath: filePath)
    }
}

extension A11yID {
    static func reviewFileKey(patchId: String, filePath: String) -> String {
        patchId + "-" + filePath.replacingOccurrences(of: "/", with: "--")
    }
}

extension A11yID {
    static func reviewFileRow(patchId: String, filePath: String) -> String {
        reviewFileRowPrefix + reviewFileKey(patchId: patchId, filePath: filePath)
    }
}

extension A11yID {
    static let reviewFindingsSection = "review-findings-section"
    static let reviewFindingAxisPrefix = "review-finding-axis-"
    static let reviewFindingRowPrefix = "review-finding-row-"
    static let reviewRiskFace = "review-risk-face"
    static func reviewFindingAxis(_ axis: String) -> String { reviewFindingAxisPrefix + axis.lowercased() }
    static func reviewFindingRow(_ id: String) -> String { reviewFindingRowPrefix + id }
}

extension A11yID {
    static let reviewGovernance = "review-governance"
    static let reviewSheet = "review-sheet"
    static let reviewChipPrefix = "review-chip-"
    static func reviewChip(_ traceId: String) -> String { reviewChipPrefix + traceId }
}

extension A11yID {
    static let reviewPatchCardPrefix = "review-patch-card-"
    static let reviewPatchDiffPrefix = "review-patch-diff-"
    static let reviewAvailableContent = "review-available-content"
    static let reviewFileRowPrefix = "review-file-row-"
    static let reviewFileAcceptPrefix = "review-file-accept-"
    static let reviewFileRejectPrefix = "review-file-reject-"
    static func reviewPatchCard(_ patchId: String) -> String { reviewPatchCardPrefix + patchId }
    static func reviewPatchDiff(_ patchId: String) -> String { reviewPatchDiffPrefix + patchId }
}

extension A11yID {
    static let reviewControlsSection = "review-controls-section"
    static let reviewTestsSection = "review-tests-section"
    static let reviewDecidedSection = "review-decided-section"
    static let reviewRunAccept = "review-run-accept"
    static let reviewRunReject = "review-run-reject"
}

extension A11yID {
    static let reviewUnavailable = "review-unavailable"
    static let reviewEmpty = "review-empty"
    static let reviewLoadFailure = "review-load-failure"
    static let reviewDiffUnavailable = "review-diff-unavailable"
    static let reviewHashWarning = "review-hash-warning"
    static let reviewRunHeader = "review-run-header"
    static let reviewToast = "review-toast"
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
