import SwiftUI
import AtlasCore

/// Filter silence surface — peel de LiveTimeline+A11y.

extension LiveTimelineA11y {
    static func spokenFilterSilenceSurface(filter: TimelineReadFilter, totalSteps: Int) -> String {
        "orquestra ao vivo, filtro \(filter.label), nenhum dos \(totalSteps) passos corresponde"
    }
}
