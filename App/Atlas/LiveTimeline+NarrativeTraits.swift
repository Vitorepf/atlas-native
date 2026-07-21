import SwiftUI
import AtlasCore

// Traits a11y — peel de LiveTimeline+NarrativeMeta.

extension NarrativeRowView {
    var currentTraits: AccessibilityTraits {
        guard isCurrent else { return [] }
        return reduceMotion ? .isSelected : [.isSelected, .updatesFrequently]
    }
}
