import SwiftUI
import AtlasCore

// Filter chip suffix — peel de LiveTimeline+A11yFilterChip.

extension LiveTimelineA11y {
    static func spokenFilterChipSuffix(active: Bool, silent: Bool) -> String {
        var suffix = ""
        if active { suffix += ", selecionado" }
        if silent { suffix += ", nenhum passo neste filtro" }
        return suffix
    }
}
