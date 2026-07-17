import SwiftUI
import UIKit
import AtlasCore

// Pick action — peel de EffortSheet.

extension EffortSheet {
    func pick(_ effort: AtlasComputeEffort) {
        model.effort = effort
        UserDefaults.standard.set(effort.rawValue, forKey: ConversationModel.effortPreferenceKey)
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        dismiss()
    }
}
