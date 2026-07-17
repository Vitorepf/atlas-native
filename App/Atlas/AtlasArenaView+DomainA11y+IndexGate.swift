import SwiftUI
import AtlasCore

// Index section gate — peel de AtlasArenaView+DomainA11y.

extension AtlasArenaView {
    func showsIndexSection(_ composite: AtlasArenaComposite) -> Bool {
        !composite.engines.isEmpty
    }
}
