import Foundation
import AtlasCore

// Last commit age — peel de AtlasCodeRadarRows+A11yRepo.

extension AtlasCodeRadarRowsA11y {
    static func spokenRepoCommitAge(lastCommitAt: Int?) -> String? {
        guard let age = AtlasCodeAge.short(from: lastCommitAt) else { return nil }
        return "último commit \(age)"
    }
}
