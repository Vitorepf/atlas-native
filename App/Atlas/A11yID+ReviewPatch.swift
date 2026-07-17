import Foundation

extension A11yID {
    // Review patch/file helpers — peel de A11yID+Review.
    static let reviewPatchCardPrefix = "review-patch-card-"
    static let reviewPatchDiffPrefix = "review-patch-diff-"
    static let reviewAvailableContent = "review-available-content"
    static let reviewFileRowPrefix = "review-file-row-"
    static let reviewFileAcceptPrefix = "review-file-accept-"
    static let reviewFileRejectPrefix = "review-file-reject-"
    static func reviewPatchCard(_ patchId: String) -> String { reviewPatchCardPrefix + patchId }
    static func reviewPatchDiff(_ patchId: String) -> String { reviewPatchDiffPrefix + patchId }
}
