import SwiftUI
import AtlasCore

// Long-press — peel de AtlasCodeCommitRow.

extension AtlasCodeCommitRow {
    func commitLongPress() {
        onLongPress?()
    }
}
