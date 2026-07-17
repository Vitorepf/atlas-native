import AtlasCore
import SwiftUI

// Arena chip spoken — peel de RootHomeSections+A11y.

extension RootHomeSections {
    func arenaSpokenLabel(regression: String?, domainUnavailable: Bool) -> String {
        if let regression { return "Arena, \(regression)" }
        if domainUnavailable { return "Arena, \(ArenaModel.domainUnavailableCopy)" }
        return "Arena, abre medição de regressão"
    }
}
