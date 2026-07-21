import Foundation

// Review file row A11yID — peel de A11yID+ReviewFiles.

extension A11yID {
    static func reviewFileRow(patchId: String, filePath: String) -> String {
        reviewFileRowPrefix + reviewFileKey(patchId: patchId, filePath: filePath)
    }
}
