import Foundation

// Folder expand hint — peel de AtlasCodeRadarFolderRow+A11y.

extension AtlasCodeFolderRowA11y {
    static func spokenHint(isExpanded: Bool) -> String {
        isExpanded ? "recolhe a pasta" : "expande a pasta"
    }
}
