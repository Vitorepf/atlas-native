import SwiftUI
import AtlasCore

// Empty predicate — peel de ArtifactSheet+EmptyGate.

extension ArtifactSheet {
    var showsEmptyOrUnavailable: Bool {
        (!loadFinished && artifacts == nil)
            || (loadFinished && artifacts == nil)
            || artifacts?.state == .unavailable
            || items.isEmpty
    }
}
