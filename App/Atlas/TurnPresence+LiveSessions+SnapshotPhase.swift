import SwiftUI
import AtlasCore

/// Phase title for live session snapshot — peel de TurnPresence+LiveSessions+SnapshotLoop.

@MainActor
extension TurnPresence {
    func liveSessionPhaseTitle(model: ConversationModel, trace: TraceID, presence: AtlasExecutionPresence) -> String {
        var phase = presence.phaseTitle
        if presence.timing == .running,
           let prog = model.bubbles.last(where: { $0.traceId == trace })?.executionProgress {
            phase = "\(prog.current)/\(prog.total) · \(prog.title)"
        }
        return phase
    }
}
