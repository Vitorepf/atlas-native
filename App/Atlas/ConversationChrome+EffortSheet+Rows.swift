import SwiftUI
import UIKit
import AtlasCore

// Effort rows — peel de ConversationChrome+EffortSheet.

extension EffortSheet {
    var effortRows: some View {
        ForEach(AtlasComputeEffort.allCases, id: \.self) { effort in
            let selected = effort == model.effort
            SheetRow(
                label: effort.shortLabel.capitalized,
                sub: ComposerSheetA11y.effortSubtitle(effort),
                selected: selected,
                accessibilityLabel: ComposerSheetA11y.effortLabel(effort, selected: selected),
                accessibilityIdentifier: A11yID.effortRow(effort.rawValue)
            ) {
                pick(effort)
            }
        }
    }
}
