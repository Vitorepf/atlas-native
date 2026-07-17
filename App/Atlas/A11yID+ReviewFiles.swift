import Foundation

// File-row A11y helpers — peel de A11yID+Review.

extension A11yID {
    private static func reviewFileKey(patchId: String, filePath: String) -> String {
        patchId + "-" + filePath.replacingOccurrences(of: "/", with: "--")
    }
    static func reviewFileRow(patchId: String, filePath: String) -> String {
        reviewFileRowPrefix + reviewFileKey(patchId: patchId, filePath: filePath)
    }
    static func reviewFileAccept(patchId: String, filePath: String) -> String {
        reviewFileAcceptPrefix + reviewFileKey(patchId: patchId, filePath: filePath)
    }
    static func reviewFileReject(patchId: String, filePath: String) -> String {
        reviewFileRejectPrefix + reviewFileKey(patchId: patchId, filePath: filePath)
    }
}
