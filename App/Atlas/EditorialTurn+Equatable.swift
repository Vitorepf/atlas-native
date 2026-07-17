import SwiftUI
import AtlasCore

// Equatable — peel de EditorialTurn.

extension EditorialTurn {
    // F2.10: igualdade só no que a tela mostra — closures recriadas pelo pai
    // não invalidam o subtree (pare com `.equatable()` no call site).
    nonisolated static func == (lhs: EditorialTurn, rhs: EditorialTurn) -> Bool {
        lhs.bubble == rhs.bubble && lhs.reduceMotion == rhs.reduceMotion && lhs.artifactItems == rhs.artifactItems
    }
}
