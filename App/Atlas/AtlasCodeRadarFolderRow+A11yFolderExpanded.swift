import Foundation
import AtlasCore

// Folder expanded state — peel de AtlasCodeRadarFolderRow+A11y.

extension AtlasCodeFolderRowA11y {
    static func spokenFolderExpanded(_ isExpanded: Bool) -> String? {
        isExpanded ? "expandida" : nil
    }
}
