import WidgetKit
import SwiftUI
import AtlasCore

// Reduce-motion transaction — peel de AtlasWidgetAccessories+LiveSession+A11yChrome.

extension LiveSessionWidgetView {
    func liveSessionA11yTransaction(_ transaction: inout Transaction) {
        if reduceMotion { transaction.disablesAnimations = true }
    }
}
