import SwiftUI
import AtlasCore

// Observation loop — peel de TurnPresence+Watch.

extension TurnPresence {
    func observe(_ id: ObjectIdentifier) {
        guard let entry = entries[id], let model = entry.model else {
            cleanup(id); return
        }
        withObservationTracking {
            _ = model.currentExecutionPresenceTraceId
            _ = model.currentExecutionPresence?.phaseTitle
            _ = model.currentExecutionPresence?.timing
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.tick(id)
                self?.observe(id)
            }
        }
    }
}
