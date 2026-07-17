import Foundation

// Review file key helper — peel de A11yID+ReviewFiles.

extension A11yID {
    static func reviewFileKey(patchId: String, filePath: String) -> String {
        patchId + "-" + filePath.replacingOccurrences(of: "/", with: "--")
    }
}
