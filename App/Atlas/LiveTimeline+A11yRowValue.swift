import SwiftUI
import AtlasCore

// Row value spoken — peel de LiveTimeline+A11yRow.

extension LiveTimelineA11y {
    static func rowValue(index: Int, total: Int, isCurrent: Bool) -> String {
        isCurrent ? "passo \(index + 1) de \(total), em andamento" : "passo \(index + 1) de \(total)"
    }
}
