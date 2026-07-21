import Foundation

// Cycle 041 fuse → A11yID.swift

/// Identifiers de acessibilidade canônicos — um único vocabulário entre a
/// casca e os XCUITests. Home/Search: +Home · Autônomos: +Autonomos ·
/// Code/radar: +Code · Arena/review: +Surfaces · Queue/Live: +QueueLive ·
/// Execution/plan: +Execution.
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
