import Foundation

/// Identifiers de acessibilidade canônicos — um único vocabulário entre a
/// casca e os XCUITests. Strings literais duplicadas quebram em silêncio nos
/// splits de view; constantes compartilhadas falham no compile.
enum A11yID {
    static let topbarCode = "topbar-code"
    static let conversationInput = "conversation-input"

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
    static let codeHealUndoWindow = "code-heal-undo-window"
    static let codeHealUndo = "code-heal-undo"
    static let codeMirror = "code-mirror"

    static let radarStatus = "radar-status"
    static let reviewGovernance = "review-governance"

    // V1 · Cockpit postura
    static let liveNowSection = "live-now-section"
    static let liveNowRowPrefix = "live-now-row-"
    static func liveNowRow(_ index: Int) -> String { liveNowRowPrefix + String(index) }

    /// Prefixo para `NSPredicate` nos UITests (slug/hash variáveis).
    static let radarRepoPrefix = "radar-repo-"
    static let radarFolderPrefix = "radar-folder-"
    static let codeCommitPrefix = "code-commit-"

    static func radarRepo(_ slug: String) -> String { radarRepoPrefix + slug }
    static func radarFolder(_ slug: String) -> String { radarFolderPrefix + slug }
    static func codeCommit(hashPrefix: String) -> String { codeCommitPrefix + hashPrefix }
}
