import Foundation

// Composer mode/effort A11yIDs — peel de A11yID+Composer.

extension A11yID {
    static let modeSheet = "composer-mode-sheet"
    static let effortSheet = "composer-effort-sheet"
    static let modeRowPrefix = "composer-mode-row-"
    static let effortRowPrefix = "composer-effort-row-"
    static func modeRow(_ key: String) -> String { modeRowPrefix + key }
    static func effortRow(_ effort: String) -> String { effortRowPrefix + effort }
}
