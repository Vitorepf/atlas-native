import Foundation

extension A11yID {
    // C15/C21 · Change review (cenas 07 + 12)
    // File helpers → A11yID+ReviewFiles.swift
    // Patch/file → A11yID+ReviewPatch.swift
    // Findings → A11yID+ReviewFindings.swift
    // Sections → A11yID+ReviewSections.swift
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
    static let reviewHashWarning = "review-hash-warning"
    static let reviewRunHeader = "review-run-header"
    static let reviewToast = "review-toast"
}
