import SwiftUI
import UIKit
import AtlasCore

// Pick action — peel de EffortSheet.

extension EffortSheet {
    func pick(_ effort: AtlasComputeEffort) {
        // Persistência é do MODEL (boundary): a View nunca toca storage.
        model.setEffort(effort)
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        dismiss()
    }
}
