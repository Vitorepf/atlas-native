import AtlasCore
import Foundation

/// Inline/rect/phase — peel de LockAccessoryA11y.
/// Phase → AtlasWidgetAccessories+LockLive+A11yPhase.swift
/// Paused → AtlasWidgetAccessories+LockLive+A11yInline+Paused.swift

extension LockAccessoryA11y {
    /// Subtítulo retangular: timer só em pausa; sessão única saudável fica quieta.
    static func rectangularSubtitle(_ snapshot: AtlasNativeSnapshot) -> String? {
        guard let sessions = snapshot.liveSessions, let first = sessions.first else {
            return "nenhuma sessão viva agora"
        }
        if first.timing == .paused {
            return rectangularPausedSubtitle(first)
        }
        if sessions.count > 1 { return "\(sessions.count) sessões vivas" }
        return nil
    }
}
