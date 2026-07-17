import SwiftUI
import AtlasCore

// Entry cleanup — peel de TurnPresence+Watch.

extension TurnPresence {
    /// Model desalocado (conversa fechada): encerra a activity órfã com honestidade.
    func cleanup(_ id: ObjectIdentifier) {
        guard let entry = entries.removeValue(forKey: id) else { return }
        if entry.ongoing { finishActivity(entry, presence: nil, phaseOverride: "sessão encerrada") }
        broadcastCount()
        syncRunning()
    }
}
