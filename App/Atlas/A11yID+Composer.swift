import Foundation

// Composer sheet A11yIDs — peel de A11yID.swift (régua ≤100).

extension A11yID {
    static let modeSheet = "composer-mode-sheet"
    static let effortSheet = "composer-effort-sheet"
    static let workspaceSheet = "composer-workspace-sheet"
    static let modeRowPrefix = "composer-mode-row-"
    static let effortRowPrefix = "composer-effort-row-"
    static let workspaceRowPrefix = "composer-workspace-row-"

    static func modeRow(_ key: String) -> String { modeRowPrefix + key }
    static func effortRow(_ effort: String) -> String { effortRowPrefix + effort }
    static func workspaceRow(_ key: String) -> String { workspaceRowPrefix + key }

    static let draftPrefix = "composer-draft-"
    static let draftRemovePrefix = "composer-draft-remove-"
    static func draft(_ id: String) -> String { draftPrefix + id }
    static func draftRemove(_ id: String) -> String { draftRemovePrefix + id }

    static let cameraPicker = "composer-camera-picker"
    static let attachmentsSheet = "composer-attachments-sheet"
    static let attachmentPhoto = "composer-attachment-photo"
    static let attachmentFile = "composer-attachment-file"
    static let attachmentPaste = "composer-attachment-paste"
}
