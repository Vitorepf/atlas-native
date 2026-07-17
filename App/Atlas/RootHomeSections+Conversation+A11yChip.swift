import AtlasCore
import SwiftUI

/// Filter chip spoken — peel de RootHomeSections+Conversation+A11y.

extension RootHomeSections {
    func filterChipSpokenLabel(_ label: String, active: Bool) -> String {
        active ? "filtro \(label), selecionado" : "filtro \(label)"
    }
}
