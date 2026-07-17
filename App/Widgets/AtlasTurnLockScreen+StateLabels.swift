import SwiftUI
import ActivityKit
import AtlasCore

/// Progress / queue labels — peel de AtlasTurnLockScreen+State.

extension AtlasTurnAttributes.ContentState {
    var progressLabel: String? {
        guard let current = progressCurrent, let total = progressTotal, total > 0 else { return nil }
        return "\(min(max(current, 0), total))/\(total)"
    }

    var queueLabel: String? {
        guard let count = queuedCount, count > 0 else { return nil }
        return "fila \(count)"
    }
}
