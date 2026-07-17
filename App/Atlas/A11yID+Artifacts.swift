import Foundation

// Artifacts A11yIDs — peel de A11yID+Surfaces.

extension A11yID {
    static let artifactsRow = "artifacts-row"
    static let artifactsSheet = "artifacts-sheet"
    static let artifactsEmpty = "artifacts-empty"
    static let artifactsUnavailable = "artifacts-unavailable"
    static let artifactsLoadFailure = "artifacts-load-failure"
    static let artifactsMount = "artifacts-mount"
    static let artifactsMountCheckPrefix = "artifacts-mount-check-"
    static func artifactsMountCheck(_ index: Int) -> String { artifactsMountCheckPrefix + String(index) }
    static let artifactsItemPrefix = "artifacts-item-"
    static func artifactsItem(_ index: Int) -> String { artifactsItemPrefix + String(index) }
    static let artifactsZoomImage = "artifacts-zoom-image"
}
