import Foundation

/// Identifiers de acessibilidade canônicos — um único vocabulário entre a
/// casca e os XCUITests. Strings literais duplicadas quebram em silêncio nos
/// splits de view; constantes compartilhadas falham no compile.
enum A11yID {
    static let topbarCode = "topbar-code"
    static let auditMasthead = "audit-masthead"
    static let conversationInput = "conversation-input"
    static let conversationNewMarker = "conversation-new-marker"
    static let conversationOutlineRowPrefix = "conversation-outline-row-"
    static let homeWorkspaceChips = "home-workspace-chips"
    static let homeWorkspaceChipPrefix = "home-workspace-chip-"
    static let homeLoading = "home-loading"
    static let homeOffline = "home-offline"
    static let homeRetry = "home-retry"

    // Busca (U7)
    static let searchScreen = "search-screen"
    static let searchField = "search-field"
    static let searchClear = "search-clear"
    static let searchRecentCaption = "search-recent-caption"
    static let searchEmpty = "search-empty"
    static let searchResultPrefix = "search-result-"

    // Workspace (U4)
    static let workspaceScreen = "workspace-screen"
    static let workspaceEmpty = "workspace-empty"
    static let workspaceOffline = "workspace-offline"
    static let workspaceAreaFilter = "workspace-area-filter"
    static let workspaceNewPill = "workspace-new-pill"

    static let executionReconnectBanner = "execution-reconnect-banner"
    static let executionSilenceWatchdog = "execution-silence-watchdog"
    static let executionReplayScrubber = "execution-replay-scrubber"
    static let executionProof = "execution-proof"
    static let executionStateCard = "execution-state-card"
    static let queueChip = "queue-chip"
    static let queueSheet = "queue-sheet"
    static let conversationLoadFailure = "conversation-load-failure"
    static let autonomosAwaitingYou = "autonomos-awaiting-you"
    static let autonomosDetailSheet = "autonomos-detail-sheet"
    static let autonomosDetailButtonPrefix = "autonomos-detail-button-"
    static let autonomosFleetEmpty = "autonomos-fleet-empty"
    static let autonomosFleetQuiet = "autonomos-fleet-quiet"
    static let autonomosFleetHistoryEmpty = "autonomos-fleet-history-empty"
    static let autonomosDigestSection = "autonomos-digest-section"
    static let autonomosDigestEmpty = "autonomos-digest-empty"
    static let autonomosOperationQuiet = "autonomos-operation-quiet"
    static let autonomosTransferSheet = "autonomos-transfer-sheet"

    static let codeStatus = "code-status"
    static let codeGraphTruncated = "code-graph-truncated"
    static let codeHealReceipt = "code-heal-receipt"
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
    static let codeHealUndoWindow = "code-heal-undo-window"
    static let codeHealUndo = "code-heal-undo"
    static let codeMirror = "code-mirror"

    static let radarStatus = "radar-status"
    static let reviewGovernance = "review-governance"

    // V1 · Cockpit postura
    static let liveNowSection = "live-now-section"
    static let liveNowRowPrefix = "live-now-row-"
    static let liveNowRemoteBadgePrefix = "live-now-remote-badge-"
    static func liveNowRow(_ index: Int) -> String { liveNowRowPrefix + String(index) }
    static func liveNowRemoteBadge(_ index: Int) -> String { liveNowRemoteBadgePrefix + String(index) }
    static func conversationOutlineRow(_ index: Int) -> String { conversationOutlineRowPrefix + String(index) }
    static func homeWorkspaceChip(_ key: String) -> String { homeWorkspaceChipPrefix + key }
    static func autonomosDetailButton(_ key: String) -> String { autonomosDetailButtonPrefix + key }
    static func searchResult(_ threadId: String) -> String { searchResultPrefix + threadId }

    // V2 · Proposta das 21h
    static let nightlyProposalCard = "nightly-proposal-card"
    static let nightlyProposalAccept = "nightly-proposal-accept"
    static let nightlyProposalDismiss = "nightly-proposal-dismiss"
    static let nightlyProposalMute = "nightly-proposal-mute"

    // V4 · Artifacts & Proof
    static let artifactsRow = "artifacts-row"
    static let artifactsSheet = "artifacts-sheet"
    static let artifactsEmpty = "artifacts-empty"
    static let artifactsUnavailable = "artifacts-unavailable"
    static let artifactsLoadFailure = "artifacts-load-failure"
    static let artifactsItemPrefix = "artifacts-item-"
    static func artifactsItem(_ index: Int) -> String { artifactsItemPrefix + String(index) }

    // C15 · Change review (cena 12)
    static let reviewSheet = "review-sheet"
    static let reviewUnavailable = "review-unavailable"
    static let reviewEmpty = "review-empty"
    static let reviewLoadFailure = "review-load-failure"
    static let reviewDiffUnavailable = "review-diff-unavailable"

    // V3 · Self-Construction
    static let selfReceiptSheet = "self-receipt-sheet"
    static let selfReceiptVeto = "self-receipt-veto"

    // M07 · Steering de execução
    static let steerSheet = "steer-sheet"
    static let steerInstruction = "steer-instruction"
    static let steerScope = "steer-scope"
    static let steerSubmit = "steer-submit"
    static let steerReceipt = "steer-receipt"

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

    /// Prefixo para `NSPredicate` nos UITests (slug/hash variáveis).
    static let radarRepoPrefix = "radar-repo-"
    static let radarFolderPrefix = "radar-folder-"
    static let codeCommitPrefix = "code-commit-"

    static func radarRepo(_ slug: String) -> String { radarRepoPrefix + slug }
    static func radarFolder(_ slug: String) -> String { radarFolderPrefix + slug }
    static func codeCommit(hashPrefix: String) -> String { codeCommitPrefix + hashPrefix }
    static func whyRow(_ index: Int) -> String { whyRowPrefix + String(index) }
    static func whyFileRow(_ index: Int) -> String { whyFileRowPrefix + String(index) }
}
