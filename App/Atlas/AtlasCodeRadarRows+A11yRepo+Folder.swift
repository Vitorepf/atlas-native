import Foundation
import AtlasCore

// Folder spoken — peel de AtlasCodeRadarRows+A11yRepo.

extension AtlasCodeRadarRowsA11y {
    static func spokenRepoFolder(folder: String?, showsFolder: Bool) -> [String] {
        guard showsFolder, let folder, !folder.isEmpty else { return [] }
        return ["pasta \(folder)"]
    }
}
