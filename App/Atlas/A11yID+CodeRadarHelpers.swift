import Foundation

// Code radar helpers — peel de A11yID+CodeHelpers.

extension A11yID {
    static func radarRepo(_ slug: String) -> String { radarRepoPrefix + slug }
    static func radarFolder(_ slug: String) -> String { radarFolderPrefix + slug }
}
