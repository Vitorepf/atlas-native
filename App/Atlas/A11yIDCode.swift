import Foundation

// WAVE-131 A11yID Code/Review domain

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
    static let markdownCodeBlockPrefix = "markdown-code-block-"
    static let markdownCodeCopyPrefix = "markdown-code-copy-"
    static func markdownCodeBlock(_ index: Int) -> String { markdownCodeBlockPrefix + String(index) }
    static func markdownCodeCopy(_ index: Int) -> String { markdownCodeCopyPrefix + String(index) }
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
