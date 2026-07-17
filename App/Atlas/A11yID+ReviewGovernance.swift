import Foundation

// Review governance A11yIDs — peel de A11yID+ReviewSurface.

extension A11yID {
    static let reviewGovernance = "review-governance"
    static let reviewSheet = "review-sheet"
    static let reviewChipPrefix = "review-chip-"
    static func reviewChip(_ traceId: String) -> String { reviewChipPrefix + traceId }
}
