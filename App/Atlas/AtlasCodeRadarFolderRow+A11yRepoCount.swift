import Foundation
import AtlasCore

// Repository count spoken — peel de AtlasCodeRadarFolderRow+A11y.

extension AtlasCodeFolderRowA11y {
    static func spokenRepoCount(_ repositoryCount: Int) -> String {
        repositoryCount == 1 ? "1 repositório" : "\(repositoryCount) repositórios"
    }
}
