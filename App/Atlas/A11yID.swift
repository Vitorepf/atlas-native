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
    static func liveNowRow(_ index: Int) -> String { liveNowRowPrefix + String(index) }

    // V2 · Proposta das 21h
    static let nightlyProposalCard = "nightly-proposal-card"
    static let nightlyProposalAccept = "nightly-proposal-accept"
    static let nightlyProposalDismiss = "nightly-proposal-dismiss"

    // V4 · Artifacts & Proof
    static let artifactsRow = "artifacts-row"
    static let artifactsSheet = "artifacts-sheet"
    static let artifactsItemPrefix = "artifacts-item-"
    static func artifactsItem(_ index: Int) -> String { artifactsItemPrefix + String(index) }

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
