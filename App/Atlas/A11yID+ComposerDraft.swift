import Foundation

// Draft strip A11yIDs — peel de A11yID+Composer.

extension A11yID {
    static let draftPrefix = "composer-draft-"
    static let draftRemovePrefix = "composer-draft-remove-"
    static func draft(_ id: String) -> String { draftPrefix + id }
    static func draftRemove(_ id: String) -> String { draftRemovePrefix + id }
}
