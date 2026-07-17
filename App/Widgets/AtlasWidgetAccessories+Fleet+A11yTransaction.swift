import WidgetKit
import SwiftUI
import AtlasCore

// A11y transaction — peel de AtlasWidgetAccessories+Fleet+A11yChrome.

extension FleetWidgetView {
    func fleetA11yTransaction(_ transaction: inout Transaction) {
        if reduceMotion { transaction.disablesAnimations = true }
    }
}
