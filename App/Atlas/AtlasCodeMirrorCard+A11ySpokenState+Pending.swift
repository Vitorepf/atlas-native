import AtlasCore
import SwiftUI

/// Mirror pending spoken — peel de AtlasCodeMirrorCard+A11ySpokenState.

extension AtlasCodeMirrorCard {
    func spokenMirrorPendingParts(commits: Int) -> [String] {
        ["\(commits) commit\(commits == 1 ? "" : "s") ainda só no Mac"]
    }
}
