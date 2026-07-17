import SwiftUI
import UIKit
import AtlasCore

// Failed message — peel de DraftThumb.

extension DraftThumb {
    var failedMessage: String? {
        if case .falhou(let m) = draft.state { return m }
        return nil
    }
}
