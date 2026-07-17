import Foundation

extension A11yID {
    static let codeStatus = "code-status"
    static let codeGraphTruncated = "code-graph-truncated"
    static let codeGraphFilters = "code-graph-filters"
    static let codeGraphWorktrees = "code-graph-worktrees"
    static let codeGraphFilterPrefix = "code-graph-filter-"
    static let codeHealReceipt = "code-heal-receipt"
    static let codeHealReceiptSheet = "code-heal-receipt-sheet"
    static let codeHealStepPrefix = "code-heal-step-"
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
    static let codeWeek = "code-week"
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

    static func radarRepo(_ slug: String) -> String { radarRepoPrefix + slug }
    static func radarFolder(_ slug: String) -> String { radarFolderPrefix + slug }
    static func codeCommit(hashPrefix: String) -> String { codeCommitPrefix + hashPrefix }
    static func codeGraphFilter(_ raw: String) -> String { codeGraphFilterPrefix + raw }
    static func codeHealStep(_ index: Int) -> String { codeHealStepPrefix + String(index) }
    static func whyRow(_ index: Int) -> String { whyRowPrefix + String(index) }
    static func whyFileRow(_ index: Int) -> String { whyFileRowPrefix + String(index) }
}
